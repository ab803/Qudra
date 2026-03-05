import 'package:flutter/material.dart';
import 'package:qudra_0/core/Styles/AppTextsyles.dart';
import 'package:qudra_0/core/Styles/AppColors.dart';

class MedsProgressCard extends StatelessWidget {
  final int taken;
  final int total;
  final String caption;

  const MedsProgressCard({
    super.key,
    required this.taken,
    required this.total,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Appcolors.primaryColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          // النص اليساري
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Today's Progress",
                    style: AppTextStyles.body.copyWith(
                      color: Colors.white,
                      fontSize: 12,
                      letterSpacing: 0.2,
                      height: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$taken/$total',
                      style: AppTextStyles.title.copyWith(
                        fontSize: 34,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        caption,
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // أيقونة صح دائرية يمين
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }
}