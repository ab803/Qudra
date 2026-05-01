import 'package:flutter/material.dart';
// This import enables localized text access using context.tr().
import '../../../core/Services/Localization/translation_extension.dart';
import '../models/community_post_model.dart';
import '../viewmodel/community_viewmodel.dart';

class EditPostBottomSheet extends StatefulWidget {
  final CommunityPostModel post;
  final CommunityViewModel viewModel;

  const EditPostBottomSheet({
    super.key,
    required this.post,
    required this.viewModel,
  });

  @override
  State<EditPostBottomSheet> createState() => _EditPostBottomSheetState();
}

class _EditPostBottomSheetState extends State<EditPostBottomSheet> {
  late final TextEditingController _contentController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.post.content);
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await widget.viewModel.updatePost(
      postId: widget.post.id,
      content: _contentController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.viewModel.errorMessage ?? context.tr('failed_update_post'),
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
        final isUpdating = widget.viewModel.isUpdatingPost;

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
                    // This bottom sheet title is localized for editing a post.
                    context.tr('edit_post_title'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  maxLines: 6,
                  minLines: 4,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    // This hint text is localized for updating post content.
                    hintText: context.tr('update_post_hint'),
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
                      // This validation error is localized for empty post content.
                      return context.tr('post_empty_error');
                    }
                    if (value.trim().length < 3) {
                      // This validation error is localized for short post content.
                      return context.tr('post_too_short_error');
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