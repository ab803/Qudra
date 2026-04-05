import 'package:flutter/material.dart';

class PermissionEmptyStatesView extends StatelessWidget {
  const PermissionEmptyStatesView({
    super.key,
    required this.isLoading,
    required this.onEnableLocationPressed,
    required this.onSkipPressed,
    this.onOpenLocationSettingsPressed,
    this.helperMessage,
    this.showOpenLocationSettingsButton = false,
  });

  final bool isLoading;
  final VoidCallback onEnableLocationPressed;
  final VoidCallback onSkipPressed;
  final VoidCallback? onOpenLocationSettingsPressed;
  final String? helperMessage;
  final bool showOpenLocationSettingsButton;

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
                'قدرة',
                style: TextStyle(
                  color: Color(0xFF4B5563),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              iconTheme: const IconThemeData(color: Color(0xFF4B5563)),
            ),
            body: SafeArea(
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: Column(
                        children: [
                        const SizedBox(height: 12),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 86,
                            height: 86,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEAF2FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.location_off_rounded,
                              color: Color(0xFFEF4444),
                              size: 42,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'صلاحية الموقع غير\nمفعلة',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'نحتاج للوصول لموقعك الجغرافي للتمكن من مشاركته مع جهات اتصالك في حالة الطوارئ.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF4B5563),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (helperMessage != null && helperMessage!.trim().isNotEmpty) ...[
            const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFF59E0B).withOpacity(0.25),
            ),
          ),
          child: Text(
            helperMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF92400E),
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.5,
            ),
          ),
        ),
        ],

        const Spacer(),

    SizedBox(
    width: double.infinity,
    height: 58,
    child: ElevatedButton.icon(
    onPressed: isLoading ? null : onEnableLocationPressed,
    style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF0D6EFD),
    foregroundColor: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(22),
    ),
    ),
    icon: isLoading
    ? const SizedBox(
    width: 18,
    height: 18,
    child: CircularProgressIndicator(
    strokeWidth: 2.2,
    color: Colors.white,
    ),
    )
        : const Icon(Icons.navigation_rounded),
    label: Text(
    isLoading
    ? 'جاري التفعيل...'
        : 'تفعيل صلاحية الموقع',
    style: const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    ),
    ),
    ),
    ),

    if (showOpenLocationSettingsButton &&
    onOpenLocationSettingsPressed != null) ...[
    const SizedBox(height: 12),
    SizedBox(
    width: double.infinity,
    height: 54,
    child: OutlinedButton.icon(
    onPressed: isLoading ? null : onOpenLocationSettingsPressed,
    style: OutlinedButton.styleFrom(
    foregroundColor: const Color(0xFF0D6EFD),
    side: const BorderSide(color: Color(0xFF0D6EFD)),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
    ),
    ),
      icon: const Icon(Icons.location_on_outlined),
      label: const Text(
        'فتح إعدادات الموقع',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
    ),
    ],
      const SizedBox(height: 14),

      TextButton(
      onPressed: isLoading ? null : onSkipPressed,
      child: const Text(
      'تخطي الآن',
       style: TextStyle(
       color: Color(0xFF0D6EFD),
       fontSize: 20,
       fontWeight: FontWeight.w800,
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
}