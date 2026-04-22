import 'package:flutter/material.dart';
import '../../../../core/Styles/AppTextsyles.dart';
import 'package:go_router/go_router.dart';

class AppGuidelinesView extends StatelessWidget {
  const AppGuidelinesView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.appBarTheme.foregroundColor,
          ),
          onPressed: () => context.go('/profile'),
        ),
        title: Text(
          'App Guidelines',
          style: AppTextStyles.title.copyWith(
            fontSize: 18,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(
              color: theme.dividerColor,
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
                      color: theme.textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Learn how to make the most of Qudra\'s\naccessibility features and health tools.',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 15,
                      height: 1.5,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search for help...',
                        hintStyle: AppTextStyles.body.copyWith(
                          color: theme.inputDecorationTheme.hintStyle?.color,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: theme.inputDecorationTheme.hintStyle?.color,
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
                        _buildFilterChip(context, 'All Topics', true),
                        const SizedBox(width: 12),
                        _buildFilterChip(context, 'Accessibility', false),
                        const SizedBox(width: 12),
                        _buildFilterChip(context, 'Chatbot', false),
                        const SizedBox(width: 12),
                        _buildFilterChip(context, 'Health', false),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Guideline Cards
                  _buildGuidelineCard(
                    context,
                    icon: Icons.smart_toy,
                    title: 'Using the AI Chatbot',
                    description:
                    'Tap the message icon in the bottom menu. You can ask health-related questions or get help with app navigation.',
                  ),
                  const SizedBox(height: 16),
                  _buildGuidelineCard(
                    context,
                    icon: Icons.notifications_active,
                    title: 'Setting Medical Reminders',
                    description:
                    'Go to the Health tab and select \'Medications\'. Tap the plus (+) icon to add a new schedule and set your notification preferences.',
                  ),
                  const SizedBox(height: 16),
                  _buildGuidelineCard(
                    context,
                    icon: Icons.visibility,
                    title: 'Visual Accessibility',
                    description:
                    'Enable high-contrast mode or increase font size in Settings > Accessibility. Qudra supports screen readers across all screens.',
                  ),
                  const SizedBox(height: 16),
                  _buildGuidelineCard(
                    context,
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
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Still need help?',
                          style: AppTextStyles.title.copyWith(
                            fontSize: 16,
                            color: theme.textTheme.titleLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Our support team is available 24/7 to assist\nyou with any accessibility concerns.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body.copyWith(
                            fontSize: 14,
                            height: 1.5,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              padding:
                              const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Contact Support',
                              style: AppTextStyles.button.copyWith(
                                fontSize: 16,
                                color: theme.colorScheme.onPrimary,
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

  Widget _buildFilterChip(BuildContext context, String label, bool isSelected) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary
            : theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.dividerColor,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected
              ? theme.colorScheme.onPrimary
              : theme.textTheme.bodyMedium?.color,
        ),
      ),
    );
  }

  Widget _buildGuidelineCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String description,
      }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.title.copyWith(
                    fontSize: 16,
                    color: theme.textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 14,
                    height: 1.5,
                    color: theme.textTheme.bodyMedium?.color,
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
