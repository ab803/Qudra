import 'package:flutter/material.dart';
// This import enables localized text access using context.tr().
import '../../../core/Services/Localization/translation_extension.dart';
import '../models/community_comment_model.dart';
import '../viewmodel/community_viewmodel.dart';

class EditCommentBottomSheet extends StatefulWidget {
  final String postId;
  final CommunityCommentModel comment;
  final CommunityViewModel viewModel;

  const EditCommentBottomSheet({
    super.key,
    required this.postId,
    required this.comment,
    required this.viewModel,
  });

  @override
  State<EditCommentBottomSheet> createState() => _EditCommentBottomSheetState();
}

class _EditCommentBottomSheetState extends State<EditCommentBottomSheet> {
  late final TextEditingController _contentController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.comment.content);
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await widget.viewModel.updateComment(
      postId: widget.postId,
      commentId: widget.comment.id,
      content: _contentController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.viewModel.errorMessage ?? context.tr('failed_update_comment'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, _) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final isUpdating = widget.viewModel.isUpdatingComment(widget.comment.id);

        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: _formKey,
            child: Wrap(
              children: [
                Center(
                  child: Text(
                    // This bottom sheet title is localized for editing a comment.
                    context.tr('edit_comment_title'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  maxLines: 4,
                  minLines: 2,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    // This hint text is localized for updating comment content.
                    hintText: context.tr('update_comment_hint'),
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                    filled: true,
                    fillColor: theme.cardColor,
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
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
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isUpdating ? null : _submitUpdate,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isUpdating
                        ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: colorScheme.onPrimary,
                      ),
                    )
                        : Text(
                      // This button label is localized for saving changes.
                      context.tr('save_changes'),
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}