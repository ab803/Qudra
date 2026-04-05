import 'package:flutter/material.dart';

class EmergencyLocationStatusCard extends StatelessWidget {
  const EmergencyLocationStatusCard({
    super.key,
    required this.isLocationServiceEnabled,
    required this.isLocationPermissionGranted,
  });

  final bool isLocationServiceEnabled;
  final bool isLocationPermissionGranted;

  @override
  Widget build(BuildContext context) {
    final isReady = isLocationServiceEnabled && isLocationPermissionGranted;

    final String title =
    isReady ? 'الموقع جاهز للمشاركة' : 'الموقع غير جاهز حاليًا';

    final String subtitle = isReady
        ? 'سيتمكن التطبيق من مشاركة موقعك وقت الطوارئ.'
        : 'تحقق من تشغيل خدمة الموقع أو تفعيل الصلاحية من إعدادات الهاتف.';

    final Color statusColor =
    isReady ? const Color(0xFF16A34A) : const Color(0xFFF59E0B);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              isReady ? Icons.my_location_rounded : Icons.location_off_rounded,
              color: statusColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}