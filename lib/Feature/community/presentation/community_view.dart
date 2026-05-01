import 'package:flutter/material.dart';
// This import enables localized text access using context.tr().
import '../../../core/Services/Localization/translation_extension.dart';
import '../services/community_post_service.dart';
import '../viewmodel/community_viewmodel.dart';
import '../widgets/comments_bottom_sheet.dart';
import '../widgets/community_app_bar.dart';
import '../widgets/create_post_bottom_sheet.dart';
import '../widgets/edit_post_bottom_sheet.dart';
import '../widgets/filter_chips.dart';
import '../widgets/post_search_bar.dart';
import '../widgets/user_post_card.dart';
import '../models/community_post_model.dart';

class CommunityView extends StatefulWidget {
  const CommunityView({super.key});

  @override
  State<CommunityView> createState() => _CommunityViewState();
}

class _CommunityViewState extends State<CommunityView> {
  late final CommunityViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CommunityViewModel(CommunityPostService());
    _viewModel.loadInitialData();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _openCreatePostSheet() async {
    final theme = Theme.of(context);
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor:
      theme.bottomSheetTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) {
        return CreatePostBottomSheet(
          viewModel: _viewModel,
        );
      },
    );
    if (!mounted) return;
    if (created == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        // This snackbar shows the localized success message after creating a post.
        SnackBar(
          content: Text(context.tr('post_published_success')),
        ),
      );
    }
  }

  Future<void> _openCommentsSheet(CommunityPostModel post) async {
    final theme = Theme.of(context);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
      theme.bottomSheetTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) {
        return CommentsBottomSheet(
          post: post,
          viewModel: _viewModel,
        );
      },
    );
  }

  Future<void> _openEditPostSheet(CommunityPostModel post) async {
    final theme = Theme.of(context);
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor:
      theme.bottomSheetTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) {
        return EditPostBottomSheet(
          post: post,
          viewModel: _viewModel,
        );
      },
    );
    if (!mounted) return;
    if (updated == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        // This snackbar shows the localized success message after updating a post.
        SnackBar(
          content: Text(context.tr('post_updated_success')),
        ),
      );
    }
  }

  Future<void> _confirmDeletePost(CommunityPostModel post) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          // This dialog title is localized for deleting a post.
          title: Text(context.tr('delete_post_title')),
          // This dialog content is localized for delete confirmation.
          content: Text(
            context.tr('delete_post_confirm'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              // This button label is localized for cancel action.
              child: Text(context.tr('cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                // This button label is localized for delete action.
                context.tr('delete'),
                style: TextStyle(color: colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;

    final success = await _viewModel.deletePost(post.id);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        // This snackbar shows the localized success message after deleting a post.
        SnackBar(
          content: Text(context.tr('post_deleted_success')),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _viewModel.errorMessage ?? context.tr('failed_delete_post'),
          ),
        ),
      );
    }
  }

  Future<void> _openPostOptions(CommunityPostModel post) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor:
      theme.bottomSheetTheme.backgroundColor ?? theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                // This sheet option label is localized for editing a post.
                title: Text(context.tr('edit_post_title')),
                onTap: () {
                  Navigator.pop(sheetContext, 'edit');
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: colorScheme.error,
                ),
                title: Text(
                  // This sheet option label is localized for deleting a post.
                  context.tr('delete_post_title'),
                  style: TextStyle(color: colorScheme.error),
                ),
                onTap: () {
                  Navigator.pop(sheetContext, 'delete');
                },
              ),
            ],
          ),
        );
      },
    );

    if (!mounted) return;

    if (action == 'edit') {
      await _openEditPostSheet(post);
    } else if (action == 'delete') {
      await _confirmDeletePost(post);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CommunityAppBar(),
                const SizedBox(height: 8),
                // ✅ Search bar is now wired to the view model.
                PostSearchBar(
                  onChanged: (value) {
                    _viewModel.updateSearchQuery(value);
                  },
                ),
                const SizedBox(height: 4),
                FilterChips(
                  selectedTab: _viewModel.selectedTab,
                  onTabSelected: (value) {
                    _viewModel.setSelectedTab(value);
                  },
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: _buildBody(),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _openCreatePostSheet,
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            child: const Icon(Icons.edit),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_viewModel.isLoading && _viewModel.displayedPosts.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: colorScheme.primary,
        ),
      );
    }

    if (_viewModel.errorMessage != null && _viewModel.displayedPosts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _viewModel.errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.error,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _viewModel.refreshCurrentTab();
                },
                // This retry button label is localized.
                child: Text(context.tr('retry')),
              ),
            ],
          ),
        ),
      );
    }

    if (_viewModel.displayedPosts.isEmpty) {
      return Center(
        child: Text(
          // This empty state label is localized when there are no posts.
          context.tr('no_posts_found'),
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 16,
            color: colorScheme.onSurface.withOpacity(0.68),
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: colorScheme.primary,
      onRefresh: _viewModel.refreshCurrentTab,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 90),
        itemCount: _viewModel.displayedPosts.length,
        itemBuilder: (context, index) {
          final post = _viewModel.displayedPosts[index];
          final subtitle =
              '${post.disabilityType} • ${_viewModel.formatTimeAgo(post.createdAt)}';
          final isOwner = _viewModel.isCurrentUserPost(post);

          return UserPostCard(
            name: post.authorName,
            subtitle: subtitle,
            body: post.content,
            likesCount: post.likesCount,
            commentsCount: post.commentsCount,
            isLiked: post.isLikedByCurrentUser,
            showMoreButton: isOwner,
            onMoreTap: isOwner
                ? () {
              _openPostOptions(post);
            }
                : null,
            onLikeTap: () async {
              await _viewModel.toggleLike(post);
              if (!mounted) return;
              if (_viewModel.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_viewModel.errorMessage!),
                  ),
                );
              }
            },
            onCommentTap: () {
              _openCommentsSheet(post);
            },
          );
        },
      ),
    );
  }
}