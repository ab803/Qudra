import 'package:flutter/material.dart';
import '../../../core/Styles/AppColors.dart';
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
            widget.viewModel.errorMessage ?? 'Failed to update comment',
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
                const Center(
                  child: Text(
                    'Edit Comment',
                    style: TextStyle(
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
                    hintText: 'Update your comment...',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      borderSide: BorderSide(
                        color: Appcolors.primaryColor,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Comment cannot be empty';
                    }

                    if (value.trim().length < 2) {
                      return 'Comment is too short';
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
                      backgroundColor: Appcolors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isUpdating
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      'Save Changes',
                      style: TextStyle(
                        color: Colors.white,
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