import 'package:flutter/material.dart';
import 'package:qudra_0/core/Styles/AppColors.dart';
import 'package:qudra_0/core/Styles/AppTextsyles.dart';

import '../../widgets/meds_header.dart';
import '../../widgets/meds_progress_card.dart';
import '../../widgets/meds_reminder_tile.dart';
import '../../widgets/meds_section_title.dart';






class MedicalRemindersView extends StatelessWidget {
  const MedicalRemindersView({super.key});

  @override
  Widget build(BuildContext context) {
    // بيانات UI ثابتة للعرض فقط – وقت الربط هتملاها من الـ DB
    final reminders = [
      ReminderViewData(
        id: 'rx_aspirin',
        title: 'Aspirin',
        subtitle: '100mg',
        timeText: '8:00 AM',
        icon: Icons.medication_liquid_outlined,
        accent: const Color(0xFFD1FAE5), // أخضر فاتح
        accentBorder: Appcolors.cardGreen,
        isEnabled: true,
        isDimmedTime: true, // في السكرين الوقت معمول strike-through
      ),
      ReminderViewData(
        id: 'rx_eye_drops',
        title: 'Eye Drops',
        subtitle: '2 drops',
        timeText: '9:30 AM',
        icon: Icons.water_drop_outlined,
        accent: const Color(0xFFE0F2FE), // أزرق فاتح
        accentBorder: Appcolors.cardBlue,
        isEnabled: true,
      ),
      ReminderViewData(
        id: 'rx_metformin',
        title: 'Metformin',
        subtitle: '500mg • 12:00 PM',
        timeText: null, // حسب السكرين مكتوبة في السطر التاني، مش خانة وقت على اليمين
        icon: Icons.circle_outlined,
        accent: const Color(0xFFFFF7ED), // أورنج فاتح
        accentBorder: Appcolors.cardOrange,
        isEnabled: false,
        isElevated: true, // لها ظلّ وحد بارز في السكرين
      ),
      ReminderViewData(
        id: 'rx_lisinopril',
        title: 'Lisinopril',
        subtitle: '10mg • 6:00 PM',
        timeText: null,
        icon: Icons.favorite_border,
        accent: const Color(0xFFF3E8FF), // بنفسجي فاتح
        accentBorder: Appcolors.cardPurple,
        isEnabled: false,
      ),
      ReminderViewData(
        id: 'rx_insulin',
        title: 'Insulin',
        subtitle: '20 Units • 9:00 PM',
        timeText: null,
        icon: Icons.science_outlined,
        accent: const Color(0xFFE0F2F1), // teal فاتح
        accentBorder: Appcolors.cardTeal,
        isEnabled: false,
      ),
    ];

    return Scaffold(
      backgroundColor: Appcolors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Appcolors.primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: false,
        titleSpacing: 0,
        title: const SizedBox.shrink(), //
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Appcolors.primaryColor),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 90), // مسافة لزر +
              children: [
                // Header
                const MedsHeader(),

                const SizedBox(height: 14),

                // Progress Card
                const MedsProgressCard(
                  taken: 2,
                  total: 5,
                  caption: 'Medicines Taken',
                ),

                const SizedBox(height: 18),

                // Section: Daily Reminders
                const MedsSectionTitle(
                  icon: Icons.wb_sunny_outlined,
                  label: 'Daily Reminders',
                ),

                const SizedBox(height: 12),

                // Reminder items
                ...reminders.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: MedsReminderTile(data: r),
                )),

                const SizedBox(height: 12),

                // Contacts row

              ],
            ),

            // Floating Add (+) — أسفل يمين بدون ناف بار
            Positioned(
              right: 16,
              bottom: 16,
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Appcolors.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }
}