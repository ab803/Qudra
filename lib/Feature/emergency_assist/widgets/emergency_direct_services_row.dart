import 'package:flutter/material.dart';

class EmergencyDirectServicesRow extends StatelessWidget {
  const EmergencyDirectServicesRow({
    super.key,
    required this.onPolicePressed,
    required this.onAmbulancePressed,
    required this.onFirePressed,
  });

  final VoidCallback onPolicePressed;
  final VoidCallback onAmbulancePressed;
  final VoidCallback onFirePressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'خدمات الطوارئ المباشرة',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _ServiceCard(
                title: 'الشرطة',
                subtitle: '122',
                icon: Icons.local_police_outlined,
                onTap: onPolicePressed,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ServiceCard(
                title: 'الإسعاف',
                subtitle: '123',
                icon: Icons.medical_services_outlined,
                onTap: onAmbulancePressed,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ServiceCard(
                title: 'المطافي',
                subtitle: '180',
                icon: Icons.local_fire_department_outlined,
                onTap: onFirePressed,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: const Color(0xFFDC0909),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}