import 'package:flutter/material.dart';
import '../../../../core/Styles/AppColors.dart';
import '../../../../core/Styles/AppTextsyles.dart';
import 'package:go_router/go_router.dart';

class AppGuidelinesView extends StatelessWidget {
  const AppGuidelinesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Appcolors.primaryColor),
          onPressed: () => context.go('/profile'),
        ),
        title: Text(
          'App Guidelines',
          style: AppTextStyles.title.copyWith(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(
              color: Appcolors.backgroundColor,
              thickness: 1,
              height: 1,
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How can we help?',
                    style: AppTextStyles.title.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Learn how to make the most of Qudra\'s\naccessibility features and health tools.',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 15,
                      height: 1.5,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search for help...',
                        hintStyle: AppTextStyles.body.copyWith(
                          color: const Color(0xFF9CA3AF),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF9CA3AF),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All Topics', true),
                        const SizedBox(width: 12),
                        _buildFilterChip('Accessibility', false),
                        const SizedBox(width: 12),
                        _buildFilterChip('Chatbot', false),
                        const SizedBox(width: 12),
                        _buildFilterChip('Health', false),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Guideline Cards
                  _buildGuidelineCard(
                    icon: Icons.smart_toy,
                    title: 'Using the AI Chatbot',
                    description:
                        'Tap the message icon in the bottom menu. You can ask health-related questions or get help with app navigation.',
                  ),
                  const SizedBox(height: 16),

                  _buildGuidelineCard(
                    icon: Icons.notifications_active,
                    title: 'Setting Medical Reminders',
                    description:
                        'Go to the Health tab and select \'Medications\'. Tap the plus (+) icon to add a new schedule and set your notification preferences.',
                  ),
                  const SizedBox(height: 16),

                  _buildGuidelineCard(
                    icon: Icons.visibility,
                    title: 'Visual Accessibility',
                    description:
                        'Enable high-contrast mode or increase font size in Settings > Accessibility. Qudra supports screen readers across all screens.',
                  ),
                  const SizedBox(height: 16),

                  _buildGuidelineCard(
                    icon: Icons.emergency,
                    title: 'SOS Features',
                    description:
                        'Configure emergency contacts in your profile. You can trigger an alert by triple-tapping the power button while Qudra is open.',
                  ),
                  const SizedBox(height: 32),

                  // Still need help section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Still need help?',
                          style: AppTextStyles.title.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Our support team is available 24/7 to assist\nyou with any accessibility concerns.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body.copyWith(
                            fontSize: 14,
                            height: 1.5,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Contact Support',
                              style: AppTextStyles.button.copyWith(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? Colors.white : const Color(0xFF4B5563),
        ),
      ),
    );
  }

  Widget _buildGuidelineCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.black, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.title.copyWith(fontSize: 16)),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 14,
                    height: 1.5,
                    color: const Color(0xFF6B7280),
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
