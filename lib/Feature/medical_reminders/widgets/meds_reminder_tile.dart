import 'package:flutter/material.dart';
import 'package:qudra_0/core/Styles/AppTextsyles.dart';
import 'package:qudra_0/core/Styles/AppColors.dart';

/// بيانات واجهة فقط – تجهّزها من الـ DB لاحقًا
class ReminderViewData {
  final String id;
  final String title;
  final String subtitle;
  final String? timeText;
  final IconData icon;
  final Color accent;
  final Color accentBorder;
  final bool isEnabled;
  final bool isDimmedTime;
  final bool isElevated;

  ReminderViewData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.accentBorder,
    this.timeText,
    this.isEnabled = false,
    this.isDimmedTime = false,
    this.isElevated = false,
  });
}

class MedsReminderTile extends StatelessWidget {
  final ReminderViewData data;
  const MedsReminderTile({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: data.isElevated
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ]
            : [],
      ),
      child: Row(
        children: [
          // أيقونة
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: data.accent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: data.accentBorder.withOpacity(0.6)),
            ),
            child: Icon(
              data.icon,
              color: Appcolors.primaryColor,
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          // النصوص
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: AppTextStyles.body.copyWith(
                    color: Appcolors.primaryColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        data.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 12.5,
                          height: 1.1,
                          color: Appcolors.secondaryColor,
                        ),
                      ),
                    ),
                    if (data.timeText != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        data.timeText!,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 12.5,
                          height: 1.1,
                          color: data.isDimmedTime
                              ? Appcolors.secondaryColor.withOpacity(0.5)
                              : Appcolors.secondaryColor,
                          decoration: data.isDimmedTime
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // سويتش UI فقط
          Opacity(
            opacity: data.isEnabled ? 1.0 : 0.6,
            child: Switch.adaptive(
              value: data.isEnabled,
              onChanged: null, // لما تربطها بالداتا هنفعلها
              activeColor: Colors.white,
              activeTrackColor: Appcolors.primaryColor,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.black12,
            ),
          ),
        ],
      ),
    );
  }
}