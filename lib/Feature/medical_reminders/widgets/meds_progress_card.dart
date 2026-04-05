import 'package:flutter/material.dart';
import 'package:qudra_0/core/Styles/AppTextsyles.dart';
import 'package:qudra_0/core/Styles/AppColors.dart';

class MedsProgressCard extends StatelessWidget {
  final int taken;
  final int total;
  final String caption;
  final String footerText;
  final int missedCount;

  const MedsProgressCard({
    super.key,
    required this.taken,
    required this.total,
    required this.caption,
    required this.footerText,
    required this.missedCount,
  });

  @override
  Widget build(BuildContext context) {
    final double progress =
    total <= 0 ? 0.0 : (taken / total).clamp(0.0, 1.0).toDouble();

    final bool isComplete = total > 0 && taken >= total;
    final bool hasMissed = missedCount > 0;

    final IconData centerIcon = isComplete
        ? Icons.check_rounded
        : hasMissed
        ? Icons.warning_amber_rounded
        : Icons.access_time_rounded;

    return Container(
      height: 116,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Appcolors.primaryColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
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
                const SizedBox(height: 8),
                Text(
                  footerText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white.withOpacity(0.92),
                    fontSize: 12.5,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 58,
            height: 58,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 58,
                  height: 58,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 5,
                    backgroundColor: Colors.white.withOpacity(0.16),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.greenAccent,
                    ),
                  ),
                ),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    centerIcon,
                    color: Colors.greenAccent,
                    size: 22,
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
