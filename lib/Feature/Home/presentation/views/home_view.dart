import 'package:flutter/material.dart';
import '../../../../core/Styles/AppColors.dart';
import '../widgets/Category_section.dart';
import '../widgets/QuickSection.dart';
import '../widgets/Recommended_section.dart';
import '../widgets/custom_searchBar.dart';
import '../widgets/home_header.dart';


class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Appcolors.backgroundColor, // Use background color
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              HomeHeader(),
              SizedBox(height: 24),
              CustomSearchBar(),
              SizedBox(height: 24),
              CategorySection(),
              SizedBox(height: 24),
              RecommendedSection(),
              SizedBox(height: 24),
              QuickAccessSection(),
              SizedBox(height: 24), // Add space at the bottom
            ],
          ),
        ),
      ),

    );
  }
}
