import 'package:flutter/material.dart';

import '../models/emergency_contact_model.dart';
import '../viewmodel/emergency_active_emergency_viewmodel.dart';

class EmergencyActiveEmergencyView extends StatefulWidget {
  const EmergencyActiveEmergencyView({
    super.key,
    required this.viewModel,
    this.onOpenEmergencyCardPressed,
    this.onImSafePressed,
  });

  final EmergencyActiveEmergencyViewModel viewModel;
  final Future<void> Function()? onOpenEmergencyCardPressed;
  final Future<void> Function()? onImSafePressed;

  @override
  State<EmergencyActiveEmergencyView> createState() =>
      _EmergencyActiveEmergencyViewState();
}

class _EmergencyActiveEmergencyViewState
    extends State<EmergencyActiveEmergencyView> {
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

  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildQuickCallButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onPressed,
    Color backgroundColor = Colors.white,
    Color iconColor = const Color(0xFF0D6EFD),
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactTile(EmergencyContactModel contact) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16),
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
              children: [
                Row(
                  children: [
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
                    if (contact.isPrimary) ...[
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
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              await widget.viewModel.callContact(contact.phoneNumber);
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

  Widget _buildActiveEmergencyHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFEF4444),
            Color(0xFFF87171),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withOpacity(0.28),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Column(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.white,
            size: 34,
          ),
          SizedBox(height: 10),
          Text(
            'تم تفعيل حالة الطوارئ',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'يمكنك الآن مشاركة حالتك أو موقعك أو التواصل مباشرة مع خدمات الطوارئ.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(EmergencyActiveEmergencyViewModel vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الموقع الحالي',
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            vm.isLocationAvailable
                ? (vm.currentLocationUrl ?? 'الموقع متاح')
                : 'الموقع غير متاح حاليًا',
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareActions(EmergencyActiveEmergencyViewModel vm) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            onPressed: () async {
              await vm.sendUrgentWhatsAppAlert();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            icon: const Icon(Icons.campaign_rounded),
            label: const Text(
              'ارسال استغاثه عاجله',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 58,
          child: OutlinedButton.icon(
            onPressed: () async {
              if (widget.onOpenEmergencyCardPressed != null) {
                await widget.onOpenEmergencyCardPressed!();
              } else {
                _showSnackBar('سيتم ربط بطاقة الطوارئ في Phase 7.');
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF111827),
              side: const BorderSide(
                color: Color(0xFFE5E7EB),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
            ),
            icon: const Icon(Icons.badge_outlined),
            label: const Text(
              'فتح البطاقة',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickCalls(EmergencyActiveEmergencyViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'اتصال مباشر',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _buildQuickCallButton(
              title: 'الطوارئ',
              subtitle: '112',
              icon: Icons.call_outlined,
              iconColor: const Color(0xFFEF4444),
              onPressed: () async {
                await vm.callUnifiedEmergency();
              },
            ),
            const SizedBox(width: 12),
            _buildQuickCallButton(
              title: 'الشرطة',
              subtitle: '122',
              icon: Icons.local_police_outlined,
              onPressed: () async {
                await vm.callPolice();
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildQuickCallButton(
              title: 'الإسعاف',
              subtitle: '123',
              icon: Icons.medical_services_outlined,
              onPressed: () async {
                await vm.callAmbulance();
              },
            ),
            const SizedBox(width: 12),
            _buildQuickCallButton(
              title: 'المطافي',
              subtitle: '180',
              icon: Icons.local_fire_department_outlined,
              onPressed: () async {
                await vm.callFire();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactsSection(EmergencyActiveEmergencyViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'جهات اتصال الطوارئ',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        if (vm.contacts.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Text(
              'لا توجد جهات اتصال للطوارئ حتى الآن.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else
          Column(
            children: vm.contacts
                .take(3)
                .map(
                  (contact) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildContactTile(contact),
              ),
            )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildImSafeButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () async {
          if (widget.onImSafePressed != null) {
            await widget.onImSafePressed!();
          } else {
            if (!mounted) return;
            Navigator.of(context).pop();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF10B981),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        icon: const Icon(Icons.check_circle_outline),
        label: const Text(
          'أنا بخير',
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
        builder: (context, _) {
          final vm = widget.viewModel;

          return Scaffold(
            backgroundColor: const Color(0xFFF6F7F9),
            appBar: AppBar(
              backgroundColor: const Color(0xFFF6F7F9),
              elevation: 0,
              surfaceTintColor: const Color(0xFFF6F7F9),
              centerTitle: true,
              title: const Text(
                'حالة طوارئ نشطة',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
            ),
            body: SafeArea(
              child: vm.isLoading
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                children: [
                  _buildActiveEmergencyHeader(),
                  const SizedBox(height: 20),
                  _buildLocationCard(vm),
                  const SizedBox(height: 20),
                  _buildShareActions(vm),
                  const SizedBox(height: 28),
                  _buildQuickCalls(vm),
                  const SizedBox(height: 28),
                  _buildContactsSection(vm),
                  const SizedBox(height: 28),
                  _buildImSafeButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}