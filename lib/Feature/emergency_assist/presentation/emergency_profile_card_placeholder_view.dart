import 'package:flutter/material.dart';

class EmergencyProfileCardPlaceholderView extends StatelessWidget {
  const EmergencyProfileCardPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'بطاقة الطوارئ',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 22,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'تم اجتياز Phase 6 بنجاح.\nسيتم بناء بطاقة الطوارئ الكاملة في Phase 7.',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
