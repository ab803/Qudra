import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qudra_0/Feature/Home/presentation/widgets/Quick_access_card.dart';
import '../../../../core/Styles/AppColors.dart';
import '../../../../core/Styles/AppTextsyles.dart';

class QuickAccessSection extends StatelessWidget {
  const QuickAccessSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Section title
        Text(
          'Quick Access',
          style: AppTextStyles.title.copyWith(
            color: Appcolors.primaryColor,
          ),
        ),

        const SizedBox(height: 16),

        // Emergency card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEF4444), Color(0xFFF87171)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF4444).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: Row(
            children: [

              // Emergency icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.medical_services,
                  color: Appcolors.primaryColor,
                ),
              ),

              const SizedBox(width: 16),

              // Text info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Emergency Call',
                    style: AppTextStyles.subtitle.copyWith(
                      color: Appcolors.primaryColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Get immediate assistance',
                    style: AppTextStyles.body.copyWith(
                      color: Appcolors.primaryColor,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 16,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Two quick cards row
        Row(
          children: [
            Expanded(
              child: QuickAccessCard(
                title: 'Chatbot',
                subtitle: 'Assistant',
                icon: Icons.smart_toy,
                color: Appcolors.cardTeal,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: QuickAccessCard(
                title: 'Medical',
                subtitle: 'Reminders',
                icon: Icons.medication,
                color: Appcolors.cardGreen,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Accessibility card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [

              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Appcolors.rateColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.menu_book, color: Appcolors.rateColor),
              ),

              const SizedBox(width: 16),

              // Text info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Accessibility', style: AppTextStyles.subtitle),
                  Text('Guidelines', style: AppTextStyles.body),
                  SizedBox(height: 4),
                  Text('Learn your rights & tips', style: AppTextStyles.body),
                ],
              ),

              const Spacer(),

              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Appcolors.secondaryColor,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
