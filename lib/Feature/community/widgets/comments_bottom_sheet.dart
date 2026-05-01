import 'package:flutter/material.dart';
// This import enables localized text access using context.tr().
import '../../../core/Services/Localization/translation_extension.dart' show TranslateExtension;
import '../models/community_comment_model.dart';
import '../models/community_post_model.dart';
import '../viewmodel/community_viewmodel.dart';
import 'comment_item.dart';
import 'edit_comment_bottom_sheet.dart';

class CommentsBottomSheet extends StatefulWidget {
  final CommunityPostModel post;
  final CommunityViewModel viewModel;

  const CommentsBottomSheet({
    super.key,
    required this.post,
    required this.viewModel,
  });

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    widget.viewModel.loadComments(widget.post.id);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await widget.viewModel.addComment(
      postId: widget.post.id,
      content: _commentController.text,
    );

    if (!mounted) return;

    if (success) {
      _commentController.clear();
      FocusScope.of(context).unfocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.viewModel.errorMessage ?? context.tr('failed_add_comment'),
          ),
        ),
      );
    }
  }

  Future<void> _openEditCommentSheet(CommunityCommentModel comment) async {
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
        return EditCommentBottomSheet(
          postId: widget.post.id,
          comment: comment,
          viewModel: widget.viewModel,
        );
      },
    );

    if (!mounted) return;

    if (updated == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        // This snackbar shows the localized success message after updating a comment.
        SnackBar(
          content: Text(context.tr('comment_updated_success')),
        ),
      );
    }
  }

  Future<void> _confirmDeleteComment(CommunityCommentModel comment) async {
    final colorScheme = Theme.of(context).colorScheme;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          // This dialog title is localized for deleting a comment.
          title: Text(context.tr('delete_comment_title')),
          // This dialog content is localized for delete confirmation.
          content: Text(
            context.tr('delete_comment_confirm'),
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

    final success = await widget.viewModel.deleteComment(
      postId: widget.post.id,
      commentId: comment.id,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        // This snackbar shows the localized success message after deleting a comment.
        SnackBar(
          content: Text(context.tr('comment_deleted_success')),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.viewModel.errorMessage ?? context.tr('failed_delete_comment'),
          ),
        ),
      );
    }
  }

  Future<void> _openCommentOptions(CommunityCommentModel comment) async {
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
                // This sheet option label is localized for editing a comment.
                title: Text(context.tr('edit_comment_title')),
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
                  // This sheet option label is localized for deleting a comment.
                  context.tr('delete_comment_title'),
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
      await _openEditCommentSheet(comment);
    } else if (action == 'delete') {
      await _confirmDeleteComment(comment);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, _) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final comments = widget.viewModel.getCommentsForPost(widget.post.id);
        final isLoading = widget.viewModel.isCommentsLoading(widget.post.id);
        final isAdding = widget.viewModel.isAddingComment(widget.post.id);

        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.72,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: theme.dividerColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      // This bottom sheet title is localized for comments.
                      context.tr('comments_title'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: isLoading
                        ? Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    )
                        : comments.isEmpty
                        ? Center(
                      child: Text(
                        // This empty state label is localized when there are no comments.
                        context.tr('no_comments'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color:
                          colorScheme.onSurface.withOpacity(0.68),
                          fontSize: 15,
                        ),
                      ),
                    )
                        : ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        final subtitle = widget.viewModel
                            .formatTimeAgo(comment.createdAt);
                        final isOwner = widget.viewModel
                            .isCurrentUserComment(comment);

                        return CommentItem(
                          authorName: comment.authorName,
                          subtitle: subtitle,
                          content: comment.content,
                          showMoreButton: isOwner,
                          onMoreTap: isOwner
                              ? () {
                            _openCommentOptions(comment);
                          }
                              : null,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Form(
                    key: _formKey,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _commentController,
                            minLines: 1,
                            maxLines: 4,
                            decoration: InputDecoration(
                              // This hint text is localized for comment input.
                              hintText: context.tr('write_comment_hint'),
                              hintStyle:
                              theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.5),
                              ),
                              filled: true,
                              fillColor: theme.cardColor,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: theme.dividerColor,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: theme.dividerColor,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(16),
                                ),
                                borderSide: BorderSide(
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                // This validation error is localized for empty comment content.
                                return context.tr('comment_empty_error');
                              }
                              if (value.trim().length < 2) {
                                // This validation error is localized for short comment content.
                                return context.tr('comment_too_short_error');
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 52,
                          width: 52,
                          child: ElevatedButton(
                            onPressed: isAdding ? null : _submitComment,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: isAdding
                                ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: colorScheme.onPrimary,
                              ),
                            )
                                : Icon(
                              Icons.send,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}