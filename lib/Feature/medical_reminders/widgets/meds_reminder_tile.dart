import 'package:flutter/material.dart';
import 'package:qudra_0/core/Styles/AppTextsyles.dart';
import 'package:qudra_0/core/Styles/AppColors.dart';

/// بيانات واجهة فقط – تجهّزها من الـ DB لاحقًا
class ReminderViewData {
  final String id;              // ID من الداتابيز
  final String title;           // اسم الدواء
  final String subtitle;        // جرعة + وقت (لو حابب في نفس السطر)
  final String? timeText;       // خانة الوقت الييمين (لو موجودة)
  final IconData icon;          // أيقونة الرمز على اليسار
  final Color accent;           // لون الخلفية الفاتح للأيقونة
  final Color accentBorder;     // لون إطار الأيقونة
  final bool isEnabled;         // حالة السويتش (UI فقط)
  final bool isDimmedTime;      // يخلي الوقت مضروب أو بلون باهت
  final bool isElevated;        // ظلّ أعلى (زي Metformin)
  final bool leadingBadge;      // دائرة بارزة على الحافة

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
    this.leadingBadge = false,
  });
}

class MedsReminderTile extends StatelessWidget {
  final ReminderViewData data;
  const MedsReminderTile({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final card = Container(
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
          // أيقونة بداخل خلفية فاتحة وحدود ملوّنة
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

          // سويتش شكلي (UI فقط) – مش شغال دلوقتي
          Opacity(
            opacity: data.isEnabled ? 1.0 : 0.6,
            child: Switch.adaptive(
              value: data.isEnabled,
              onChanged: null, // UI فقط (هتوصّله لما الداتا تجهز)
              activeColor: Colors.white,
              activeTrackColor: Appcolors.primaryColor,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.black12,
            ),
          ),
        ],
      ),
    );

    if (!data.leadingBadge) return card;

    // نسخة Metformin فيها حافة دائرية بلون أورنج – نحاكيها بStack
    return Stack(
      children: [
        card,
        Positioned(
          left: 10,
          top: 12,
          bottom: 12,
          child: Container(
            width: 8,
            decoration: BoxDecoration(
              color: Appcolors.cardOrange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: Appcolors.cardOrange.withOpacity(0.6)),
            ),
          ),
        ),
      ],
    );
  }
}