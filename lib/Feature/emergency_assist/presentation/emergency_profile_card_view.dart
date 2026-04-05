import 'package:flutter/material.dart';

import '../models/emergency_contact_model.dart';
import '../viewmodel/emergency_profile_card_viewmodel.dart';

class EmergencyProfileCardView extends StatefulWidget {
  const EmergencyProfileCardView({
    super.key,
    required this.viewModel,
  });

  final EmergencyProfileCardViewModel viewModel;

  @override
  State<EmergencyProfileCardView> createState() {
    return _EmergencyProfileCardViewState();
  }
}

class _EmergencyProfileCardViewState
    extends State<EmergencyProfileCardView> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadData();
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  Widget _buildSectionCard({
    required String title,
    required Widget child,
    Color backgroundColor = Colors.white,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '$label: ',
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF4B5563),
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(
      EmergencyContactModel contact,
      EmergencyProfileCardViewModel vm,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        contact.name,
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (contact.isPrimary) ...<Widget>[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF2FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'أساسي',
                          style: TextStyle(
                            color: Color(0xFF0D6EFD),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  contact.relation,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  contact.phoneNumber,
                  style: const TextStyle(
                    color: Color(0xFF4B5563),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              await vm.callContact(contact.phoneNumber);
            },
            icon: const Icon(
              Icons.call_rounded,
              color: Color(0xFF0D6EFD),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSummary(EmergencyProfileCardViewModel vm) {
    final profile = vm.profile;

    if (profile == null) {
      return _buildSectionCard(
        title: 'الملف الشخصي',
        child: const Text(
          'لا توجد بيانات ملف شخصي متاحة.',
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return _buildSectionCard(
      title: 'الملف الشخصي',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildInfoRow(
            label: 'الاسم',
            value: profile.fullName,
          ),
          _buildInfoRow(
            label: 'نوع الإعاقة',
            value: profile.disabilityType,
          ),
          _buildInfoRow(
            label: 'التواصل المناسب',
            value: vm.communicationMethodLabel,
          ),
          _buildInfoRow(
            label: 'فصيلة الدم',
            value: profile.bloodType,
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalInfo(EmergencyProfileCardViewModel vm) {
    final profile = vm.profile;

    final String medicalNotes =
    (profile?.importantMedicalNotes.trim().isNotEmpty ?? false)
        ? profile!.importantMedicalNotes
        : 'لا توجد ملاحظات طبية مسجلة.';

    final String allergies =
    (profile?.allergiesAndMedications.trim().isNotEmpty ?? false)
        ? profile!.allergiesAndMedications
        : 'لا توجد حساسية أو أدوية مسجلة.';

    return _buildSectionCard(
      title: 'المعلومات الطبية',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'ملاحظات طبية هامة',
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            medicalNotes,
            style: const TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'الحساسية والأدوية',
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            allergies,
            style: const TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsSection(EmergencyProfileCardViewModel vm) {
    return _buildSectionCard(
      title: 'جهات اتصال الطوارئ',
      child: vm.contacts.isEmpty
          ? const Text(
        'لا توجد جهات اتصال للطوارئ حتى الآن.',
        style: TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      )
          : Column(
        children: vm.contacts
            .take(3)
            .map((EmergencyContactModel contact) {
          return _buildContactTile(contact, vm);
        })
            .toList(),
      ),
    );
  }

  Widget _buildLocationSection(EmergencyProfileCardViewModel vm) {
    return _buildSectionCard(
      title: 'الموقع الحالي',
      child: Text(
        vm.isLocationAvailable
            ? (vm.currentLocationUrl ?? 'الموقع غير متاح حاليًا.')
            : 'الموقع غير متاح حاليًا.',
        style: const TextStyle(
          color: Color(0xFF4B5563),
          fontSize: 15,
          fontWeight: FontWeight.w600,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildHeader(EmergencyProfileCardViewModel vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[
            Color(0xFF111827),
            Color(0xFF374151),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        children: <Widget>[
          const Icon(
            Icons.badge_outlined,
            size: 34,
            color: Colors.white,
          ),
          const SizedBox(height: 10),
          Text(
            vm.profile?.fullName ?? 'بطاقة الطوارئ',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            vm.communicationMethodLabel,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton(EmergencyProfileCardViewModel vm) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () async {
          await vm.shareCard();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D6EFD),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        icon: const Icon(Icons.ios_share_rounded),
        label: const Text(
          'مشاركة البطاقة',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnimatedBuilder(
        animation: widget.viewModel,
        builder: (BuildContext context, _) {
          final vm = widget.viewModel;

          return Scaffold(
            backgroundColor: const Color(0xFFF6F7F9),
            appBar: AppBar(
              backgroundColor: const Color(0xFFF6F7F9),
              elevation: 0,
              surfaceTintColor: const Color(0xFFF6F7F9),
              centerTitle: true,
              title: const Text(
                'بطاقة الطوارئ',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
              iconTheme: const IconThemeData(
                color: Color(0xFF111827),
              ),
            ),
            body: SafeArea(
              child: vm.isLoading
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : vm.errorMessage != null
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    vm.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
                  : ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                children: <Widget>[
                  _buildHeader(vm),
                  const SizedBox(height: 20),
                  _buildProfileSummary(vm),
                  const SizedBox(height: 16),
                  _buildMedicalInfo(vm),
                  const SizedBox(height: 16),
                  _buildContactsSection(vm),
                  const SizedBox(height: 16),
                  _buildLocationSection(vm),
                  const SizedBox(height: 24),
                  _buildShareButton(vm),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}