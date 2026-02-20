import 'package:flutter/material.dart';
import '../../core/Styles/AppColors.dart';

import 'widgets/community_app_bar.dart';
import 'widgets/search_bar.dart' hide SearchBar;
import 'widgets/filter_chips.dart';
import 'widgets/official_post_card.dart';
import 'widgets/user_post_card.dart';

class CommunityView extends StatelessWidget {
  const CommunityView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Appcolors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              CommunityAppBar(),
              SearchBar(),
              FilterChips(),
              OfficialPostCard(),

              UserPostCard(
                avatarUrl: 'https://i.pravatar.cc/150?img=5',
                name: 'Sarah Jenkins',
                subtitle: 'Visual Impairment • 4h ago',
                tagText: 'Success Stories',
                title: 'Finally navigated the subway solo! 🚇',
                body:
                'After months of mobility training, I took the downtown line by myself today.',
                hasImage: true,
                likes: '124',
                comments: '24',
              ),

              SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Appcolors.primaryColor,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }
}