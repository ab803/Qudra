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
    Color? backgroundColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '$label: ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.72),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.dividerColor,
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withOpacity(
                theme.brightness == Brightness.dark ? 0.10 : 0.05,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.person_outline_rounded,
              color: colorScheme.onSurface.withOpacity(0.58),
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
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
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
                          color: colorScheme.primary.withOpacity(
                            theme.brightness == Brightness.dark ? 0.16 : 0.10,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'أساسي',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
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
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.68),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  contact.phoneNumber,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.82),
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
            icon: Icon(
              Icons.call_rounded,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSummary(EmergencyProfileCardViewModel vm) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final profile = vm.profile;

    if (profile == null) {
      return _buildSectionCard(
        title: 'الملف الشخصي',
        child: Text(
          'لا توجد بيانات ملف شخصي متاحة.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.68),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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
          Text(
            'ملاحظات طبية هامة',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            medicalNotes,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.72),
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'الحساسية والأدوية',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            allergies,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.72),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _buildSectionCard(
      title: 'جهات اتصال الطوارئ',
      child: vm.contacts.isEmpty
          ? Text(
        'لا توجد جهات اتصال للطوارئ حتى الآن.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withOpacity(0.68),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _buildSectionCard(
      title: 'الموقع الحالي',
      child: Text(
        vm.isLocationAvailable
            ? (vm.currentLocationUrl ?? 'الموقع غير متاح حاليًا.')
            : 'الموقع غير متاح حاليًا.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withOpacity(0.72),
          fontSize: 15,
          fontWeight: FontWeight.w600,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildHeader(EmergencyProfileCardViewModel vm) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.badge_outlined,
            size: 34,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 10),
          Text(
            vm.profile?.fullName ?? 'بطاقة الطوارئ',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            vm.communicationMethodLabel,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.68),
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
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;
          final vm = widget.viewModel;

          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                'بطاقة الطوارئ',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
            ),
            body: SafeArea(
              child: vm.isLoading
                  ? Center(
                child: CircularProgressIndicator(
                  color: colorScheme.primary,
                ),
              )
                  : vm.errorMessage != null
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    vm.errorMessage!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.error,
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
