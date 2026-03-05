import 'package:flutter/material.dart';
import '../../../../core/Styles/AppColors.dart';
import '../../../../core/Styles/AppTextsyles.dart';
import 'package:go_router/go_router.dart';

class MySubscriptionsView extends StatefulWidget {
  const MySubscriptionsView({super.key});

  @override
  State<MySubscriptionsView> createState() => _MySubscriptionsViewState();
}

class _MySubscriptionsViewState extends State<MySubscriptionsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Appcolors.primaryColor),
          onPressed: () => context.go('/profile'),
        ),
        title: Text(
          'My Subscriptions',
          style: AppTextStyles.title.copyWith(fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Appcolors.primaryColor),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          labelColor: Colors.black,
          unselectedLabelColor: const Color(0xFF6B7280),
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Expired'),
            Tab(text: 'Pending'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Active Tab
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSubscriptionCard(
                iconPath:
                    'assets/images/global_relief.png', // Placeholder, using color or default icon if image fails
                title: 'Global Relief\nFoundation',
                description: 'Supporting humanitarian aid worldwide',
                price: '\$25.00',
                renewalDate: 'Oct 12, 2023',
                iconColor: const Color(0xFF1E4646),
                icon: Icons.flag, // Fallback icon
              ),
              const SizedBox(height: 16),
              _buildSubscriptionCard(
                iconPath: 'assets/images/green_earth.png',
                title: 'Green Earth\nInitiative',
                description: 'Reforestation and carbon offsetting',
                price: '\$10.00',
                renewalDate: 'Nov 05, 2023',
                iconColor: const Color(0xFF4ADE80),
                icon: Icons.eco, // Fallback icon
              ),
              const SizedBox(height: 16),
              _buildSubscriptionCard(
                iconPath: 'assets/images/future_minds.png',
                title: 'Future Minds Tech',
                description: 'Educational support for STEM',
                price: '\$15.00',
                renewalDate: 'Dec 01, 2023',
                iconColor: const Color(0xFF4B8B8B),
                icon: Icons.desktop_windows, // Fallback icon
              ),
            ],
          ),
          // Expired Tab
          const Center(child: Text('No Expired Subscriptions')),
          // Pending Tab
          const Center(child: Text('No Pending Subscriptions')),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard({
    required String iconPath,
    required String title,
    required String description,
    required String price,
    required String renewalDate,
    required Color iconColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Icon(icon, color: Colors.white, size: 30)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppTextStyles.title.copyWith(fontSize: 16),
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: price,
                                style: AppTextStyles.title.copyWith(
                                  fontSize: 16,
                                ),
                              ),
                              TextSpan(
                                text: '/mo',
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 14,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 13,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Renewal: $renewalDate',
                          style: AppTextStyles.body.copyWith(
                            fontSize: 12,
                            color: const Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Text(
                'Manage Subscription',
                style: AppTextStyles.button.copyWith(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
