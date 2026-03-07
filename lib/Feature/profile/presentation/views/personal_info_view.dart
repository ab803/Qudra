import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qudra_0/core/Styles/AppColors.dart';
import 'package:qudra_0/core/Styles/AppTextsyles.dart';
import '../../widgets/personal_info_avatar.dart';
import '../../widgets/labeled_readonly_field.dart';
import '../../widgets/disability_profile_card.dart';

class PersonalInfoView extends StatelessWidget {
  const PersonalInfoView({super.key});

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
          onPressed: () => context.go('/profile'),
        ),
        centerTitle: true,
        title: Text(
          'Personal Info',
          style: AppTextStyles.subtitle.copyWith(
            color: Appcolors.primaryColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: const [
            PersonalInfoAvatar(),
            SizedBox(height: 12),


            _NameAndId(name: 'Name', userId: '#839210'),
            SizedBox(height: 18),

            LabeledReadonlyField(
              label: 'Full Name',
              hint: 'Name',
              prefixIcon: Icons.person_outline,
            ),
            SizedBox(height: 12),

            LabeledReadonlyField(
              label: 'Email Address',
              hint: '@example.com',
              prefixIcon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 12),

            LabeledReadonlyField(
              label: 'Phone Number',
              hint: '+1 (555) 123-4567',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 12),

            LabeledReadonlyField(
              label: 'Date of Birth',
              hint: '05/15/1992',
              prefixIcon: Icons.calendar_today_outlined,
              trailingIcon: Icons.event,
            ),

            SizedBox(height: 16),
            DisabilityProfileCard(),
            SizedBox(height: 20),

            _SaveButton(),
          ],
        ),
      ),
    );
  }
}

class _NameAndId extends StatelessWidget {
  final String name;
  final String userId;
  const _NameAndId({required this.name, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          name,
          style: AppTextStyles.subtitle.copyWith(
            color: Appcolors.primaryColor,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'User ID: $userId',
          style: AppTextStyles.body.copyWith(
            fontSize: 12,
            color: Appcolors.secondaryColor,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Appcolors.primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        onPressed: null,
        child: Text(
          'Save Changes',
          style: AppTextStyles.button.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}