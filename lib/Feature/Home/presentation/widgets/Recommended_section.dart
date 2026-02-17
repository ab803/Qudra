import 'package:flutter/material.dart';
import 'package:qudra_0/core/Styles/AppTextsyles.dart';
import '../../../../core/Styles/AppColors.dart';

class RecommendedSection extends StatelessWidget {
  const RecommendedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Section title
        Text(
          'Recommended For You',
          style: AppTextStyles.subtitle.copyWith(
            color: Appcolors.primaryColor,
          ),
        ),

        const SizedBox(height: 16),

        // Horizontal list of recommended places
        SizedBox(
          height: 240,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 2,
            separatorBuilder: (context, index) =>
            const SizedBox(width: 16),

            itemBuilder: (context, index) {
              return Container(
                width: 280,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Appcolors.primaryColor.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Image section
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://placehold.co/600x400/png',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    ),

                    // Text info
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          const SizedBox(height: 8),

                          // Title
                          Text(
                            'City Mobility Center',
                            style: AppTextStyles.subtitle.copyWith(
                              color: Appcolors.primaryColor,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Location row
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 14,
                                color: Appcolors.secondaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '1.2 miles away',
                                style: AppTextStyles.body.copyWith(
                                  color: Appcolors.secondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
