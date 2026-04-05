import 'package:flutter/material.dart';

class EmergencyProfileCardPlaceholderView extends StatelessWidget {
  const EmergencyProfileCardPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7F9),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF6F7F9),
          elevation: 0,
          surfaceTintColor: const Color(0xFFF6F7F9),
          centerTitle: true,
          title: const Text(
            'بطاقة الطوارئ',
            style: TextStyle(
              color: Color(0xFF111827),
              fontWeight: FontWeight.w800,
              fontSize: 22,
            ),
          ),
          iconTheme: const IconThemeData(
            color: Color(0xFF111827),
          ),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'تم اجتياز Phase 6 بنجاح.\nسيتم بناء بطاقة الطوارئ الكاملة في Phase 7.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
                height: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}