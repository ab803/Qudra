import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/Services/Localization/translation_extension.dart';
import '../models/emergency_contact_model.dart';

class EmergencyContactFormBottomSheet extends StatefulWidget {
  const EmergencyContactFormBottomSheet({
    super.key,
    this.initialContact,
  });

  final EmergencyContactModel? initialContact;

  @override
  State<EmergencyContactFormBottomSheet> createState() =>
      _EmergencyContactFormBottomSheetState();
}

class _EmergencyContactFormBottomSheetState
    extends State<EmergencyContactFormBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _relationController;
  late final TextEditingController _phoneController;

  bool _isPrimary = false;

  bool get isEditMode => widget.initialContact != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialContact?.name ?? '',
    );
    _relationController = TextEditingController(
      text: widget.initialContact?.relation ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.initialContact?.phoneNumber ?? '',
    );
    _isPrimary = widget.initialContact?.isPrimary ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _relationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final result = EmergencyContactModel(
      localId: widget.initialContact?.localId,
      name: _nameController.text.trim(),
      relation: _relationController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      isPrimary: _isPrimary,
      createdAt: widget.initialContact?.createdAt,
      updatedAt: DateTime.now(),
    );

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                // This title is localized for add/edit emergency contact mode.
                isEditMode
                    ? context.tr('emergency_contact_form_edit_title')
                    : context.tr('emergency_contact_form_add_title'),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  context,
                  // This hint is localized for the contact name field.
                  context.tr('emergency_contact_name_label'),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    // This validation message is localized for missing contact name.
                    return context.tr('emergency_contact_name_validation');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _relationController,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  context,
                  // This hint is localized for the contact relation field.
                  context.tr('emergency_contact_relation_label'),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    // This validation message is localized for missing contact relation.
                    return context.tr('emergency_contact_relation_validation');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                decoration: _inputDecoration(
                  context,
                  // This hint is localized for the contact phone field.
                  context.tr('emergency_contact_phone_label'),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    // This validation message is localized for missing contact phone.
                    return context.tr('emergency_contact_phone_validation');
                  }

                  final sanitized = value.trim().replaceAll(' ', '');
                  if (sanitized.length < 8) {
                    // This validation message is localized for invalid contact phone.
                    return context.tr('emergency_contact_phone_invalid');
                  }

                  return null;
                },
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Row(
                  children: [
                    Switch.adaptive(
                      value: _isPrimary,
                      onChanged: (value) {
                        setState(() {
                          _isPrimary = value;
                        });
                      },
                      activeColor: colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            // This switch title is localized for making the contact primary.
                            context.tr('emergency_contact_make_primary'),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            // This switch subtitle is localized for making the contact primary.
                            context.tr(
                              'emergency_contact_make_primary_subtitle',
                            ),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.68),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    // This button label is localized for add/edit contact mode.
                    isEditMode
                        ? context.tr('save_changes')
                        : context.tr('emergency_contact_add_single'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String hintText) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InputDecoration(
      hintText: hintText,
      hintStyle: theme.textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface.withOpacity(0.45),
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: theme.cardColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: colorScheme.primary,
          width: 1.2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: colorScheme.error,
          width: 1.0,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: colorScheme.error,
          width: 1.0,
        ),
      ),
    );
  }
}
