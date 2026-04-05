import 'package:flutter/material.dart';
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
final bottomInset = MediaQuery.of(context).viewInsets.bottom;

return Directionality(
textDirection: TextDirection.rtl,
child: Padding(
padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
child: SingleChildScrollView(
child: Form(
key: _formKey,
child: Column(
mainAxisSize: MainAxisSize.min,
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
isEditMode
? 'تعديل جهة اتصال الطوارئ'
    : 'إضافة جهة اتصال للطوارئ',
style: const TextStyle(
color: Color(0xFF111827),
fontSize: 22,
fontWeight: FontWeight.w800,
),
),
const SizedBox(height: 18),

TextFormField(
controller: _nameController,
textInputAction: TextInputAction.next,
decoration: _inputDecoration('الاسم'),
validator: (value) {
if (value == null || value.trim().isEmpty) {
return 'من فضلك أدخل الاسم';
}
return null;
},
),
const SizedBox(height: 14),

TextFormField(
controller: _relationController,
textInputAction: TextInputAction.next,
decoration: _inputDecoration('الصفة / العلاقة'),
validator: (value) {
if (value == null || value.trim().isEmpty) {
return 'من فضلك أدخل العلاقة';
}
return null;
},
),
const SizedBox(height: 14),

TextFormField(
controller: _phoneController,
keyboardType: TextInputType.phone,
textInputAction: TextInputAction.done,
decoration: _inputDecoration('رقم الهاتف'),
validator: (value) {
if (value == null || value.trim().isEmpty) {
return 'من فضلك أدخل رقم الهاتف';
}

final sanitized = value.trim().replaceAll(' ', '');
if (sanitized.length < 8) {
return 'رقم الهاتف غير صالح';
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
color: const Color(0xFFF7F7F8),
borderRadius: BorderRadius.circular(18),
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
activeColor: const Color(0xFF0D6EFD),
),
const SizedBox(width: 10),
const Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'اجعلها جهة أساسية',
style: TextStyle(

  color: Color(0xFF111827),
  fontSize: 16,
  fontWeight: FontWeight.w800,
),
),
  SizedBox(height: 4),
  Text(
    'سيتم تمييزها كأول جهة اتصال للطوارئ.',
    style: TextStyle(
      color: Color(0xFF6B7280),
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
        backgroundColor: const Color(0xFF0D6EFD),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      child: Text(
        isEditMode ? 'حفظ التعديلات' : 'إضافة جهة الاتصال',
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
),
);
}

InputDecoration _inputDecoration(String hintText) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(
      color: Color(0xFF9CA3AF),
      fontWeight: FontWeight.w500,
    ),
    filled: true,
    fillColor: const Color(0xFFEDEEF0),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 18,
      vertical: 16,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(
        color: Color(0xFF0D6EFD),
        width: 1.2,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(
        color: Colors.red,
        width: 1.0,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(
        color: Colors.red,
        width: 1.0,
      ),
    ),
  );
}
}