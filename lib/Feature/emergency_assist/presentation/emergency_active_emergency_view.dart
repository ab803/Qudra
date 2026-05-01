import 'package:flutter/material.dart';
// This import enables localized text access using context.tr().
import '../../../core/Services/Localization/translation_extension.dart';
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
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),


    );
}

Widget _buildQuickCallButton({
  required String title,
  required String subtitle,
  required IconData icon,
  required VoidCallback onPressed,
  Color? backgroundColor,
  Color? iconColor,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  return Expanded(
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        decoration: BoxDecoration(
          color: backgroundColor ?? theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          children: [
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
                icon,
                color: iconColor ?? colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.68),
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
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: theme.dividerColor),
    ),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.onSurface.withOpacity(
              theme.brightness == Brightness.dark ? 0.10 : 0.05,
            ),
            borderRadius: BorderRadius.circular(16),
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
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      contact.name,
                      style: theme.textTheme.titleMedium?.copyWith(
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
                        color: colorScheme.primary.withOpacity(
                          theme.brightness == Brightness.dark ? 0.16 : 0.10,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        context.tr('emergency_contact_primary'),
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
            ],
          ),
        ),
        IconButton(
          onPressed: () async {
            await widget.viewModel.callContact(contact.phoneNumber);
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

Widget _buildActiveEmergencyHeader() {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final headerColor = colorScheme.error;
  final headerColorSoft = colorScheme.error.withOpacity(
    theme.brightness == Brightness.dark ? 0.82 : 0.78,
  );

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          headerColor,
          headerColorSoft,
        ],
      ),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: headerColor.withOpacity(0.28),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      children: [
        Icon(
          Icons.warning_amber_rounded,
          color: colorScheme.onError,
          size: 34,
        ),
        const SizedBox(height: 10),
        Text(
          // This title is localized for an active emergency state.
          context.tr('emergency_active_title'),
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.onError,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          // This subtitle is localized for an active emergency state.
          context.tr('emergency_active_subtitle'),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onError,
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
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: theme.dividerColor),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('emergency_current_location'),
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          vm.isLocationAvailable
              ? (vm.currentLocationUrl ??
              context.tr('emergency_location_available_fallback'))
              : context.tr('emergency_location_unavailable'),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.68),
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
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
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
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          icon: const Icon(Icons.campaign_rounded),
          label: Text(
            context.tr('emergency_send_urgent_alert'),
            style: const TextStyle(
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
              _showSnackBar(context.tr('emergency_card_not_linked'));
            }
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.onSurface,
            side: BorderSide(
              color: theme.dividerColor,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: theme.cardColor,
          ),
          icon: const Icon(Icons.badge_outlined),
          label: Text(
            context.tr('emergency_open_card'),
            style: const TextStyle(
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
  final theme = Theme.of(context);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        context.tr('emergency_direct_call'),
        style: theme.textTheme.titleMedium?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 14),
      Row(
        children: [
          _buildQuickCallButton(
            title: context.tr('emergency_service_unified'),
            subtitle: '112',
            icon: Icons.call_outlined,
            iconColor: Theme.of(context).colorScheme.error,
            onPressed: () async {
              await vm.callUnifiedEmergency();
            },
          ),
          const SizedBox(width: 12),
          _buildQuickCallButton(
            title: context.tr('emergency_service_police'),
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
            title: context.tr('emergency_service_ambulance'),
            subtitle: '123',
            icon: Icons.medical_services_outlined,
            onPressed: () async {
              await vm.callAmbulance();
            },
          ),
          const SizedBox(width: 12),
          _buildQuickCallButton(
            title: context.tr('emergency_service_fire'),
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
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        context.tr('emergency_contacts_title'),
        style: theme.textTheme.titleMedium?.copyWith(
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
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Text(
            context.tr('emergency_contacts_empty_inline'),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.68),
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
  const safeColor = Color(0xFF10B981);
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
        backgroundColor: safeColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      icon: const Icon(Icons.check_circle_outline),
      label: Text(
        context.tr('emergency_im_safe'),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}

@override
Widget build(BuildContext context) {
  return AnimatedBuilder(
    animation: widget.viewModel,
    builder: (context, _) {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      final vm = widget.viewModel;

      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            context.tr('emergency_active_title'),
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
  );
}
}
