import 'package:flutter/material.dart';
import 'package:qudra_0/core/Styles/AppColors.dart';
import 'package:qudra_0/core/Styles/AppTextsyles.dart';

class ProfessionalServicesSection extends StatelessWidget {
  const ProfessionalServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PROFESSIONAL SERVICES',
          style: AppTextStyles.body.copyWith(
            letterSpacing: 2,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Appcolors.secondaryColor,
          ),
        ),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(child: _ServiceCard(title: 'POLICE', icon: Icons.shield)),
            SizedBox(width: 12),
            Expanded(child: _ServiceCard(title: 'AMBULANCE', icon: Icons.medical_services)),
            SizedBox(width: 12),
            Expanded(child: _ServiceCard(title: 'FIRE', icon: Icons.fire_truck)),
          ],
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String title;
  final IconData icon;

  const _ServiceCard({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 95,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Appcolors.backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Appcolors.primaryColor, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 1.2,
              color: Appcolors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}