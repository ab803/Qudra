import 'package:flutter/material.dart';
import 'package:qudra_0/core/Styles/AppColors.dart';
import 'package:qudra_0/core/Styles/AppTextsyles.dart';
import '../widgets/current_location_map.dart';
import '../widgets/sos_hold_button.dart';
import '../widgets/section_header.dart';
import '../widgets/professional_services_row.dart';
import '../widgets/personal_contacts_section.dart';

class EmergencyHelpView extends StatelessWidget {
  const EmergencyHelpView({super.key});

  @override
  Widget build(BuildContext context) {
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
        centerTitle: true,
        title: Text(
          'Emergency Help',
          style: AppTextStyles.subtitle.copyWith(
            color: Appcolors.primaryColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Appcolors.primaryColor),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        // ✅ ListView أفضل من SingleChildScrollView لما الصفحة فيها sections كتير
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          children: [
            const CurrentLocationMap(),
            const SizedBox(height: 22),

            const SosHoldButton(),
            const SizedBox(height: 10),

            const Center(
              child: _HoldHintText(),
            ),

            const SizedBox(height: 22),


            const SizedBox(height: 12),
            ProfessionalServicesSection(),


            const SizedBox(height: 22),

            const PersonalContactsSection(),

            const SizedBox(height: 18),
            const Center(child: _StatusFooter()),
          ],
        ),
      ),
    );
  }
}

class ProfessionalServicesRow {
}



class _HoldHintText extends StatelessWidget {
  const _HoldHintText();

  @override
  Widget build(BuildContext context) {
    return Text(
      'PRESS AND HOLD TO ACTIVATE',
      style: AppTextStyles.body.copyWith(
        letterSpacing: 2,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Appcolors.secondaryColor,
      ),
    );
  }
}

class _StatusFooter extends StatelessWidget {
  const _StatusFooter();

  @override
  Widget build(BuildContext context) {
    return Text(
      '• SIGNAL: STRONG     • GPS: ACTIVE',
      style: AppTextStyles.body.copyWith(
        fontSize: 11,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w600,
        color: Appcolors.secondaryColor,
      ),
    );
  }
}