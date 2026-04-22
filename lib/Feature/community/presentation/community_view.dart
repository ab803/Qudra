import 'package:flutter/material.dart';
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
        const SnackBar(
          content: Text('Post published successfully'),
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
        const SnackBar(
          content: Text('Post updated successfully'),
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
          title: const Text('Delete Post'),
          content: const Text(
            'Are you sure you want to delete this post?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                'Delete',
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
        const SnackBar(
          content: Text('Post deleted successfully'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _viewModel.errorMessage ?? 'Failed to delete post',
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
                title: const Text('Edit Post'),
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
                  'Delete Post',
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
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_viewModel.displayedPosts.isEmpty) {
      return Center(
        child: Text(
          'No posts found',
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
