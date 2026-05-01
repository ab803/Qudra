import 'package:flutter/material.dart';
// This import enables localized text access using context.tr().
import '../../../core/Services/Localization/translation_extension.dart';
import '../models/emergency_contact_model.dart';
import '../viewmodel/emergency_contacts_viewmodel.dart';
import '../widgets/emergency_contact_form_bottom_sheet.dart';

class EmergencyContactsView extends StatefulWidget {
  const EmergencyContactsView({
    super.key,
    required this.viewModel,
  });

  final EmergencyContactsViewModel viewModel;

  @override
  State<EmergencyContactsView> createState() => _EmergencyContactsViewState();
}

class _EmergencyContactsViewState extends State<EmergencyContactsView> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadContacts();
  }

  Future<void> _openAddBottomSheet() async {
    final theme = Theme.of(context);
    final result = await showModalBottomSheet<EmergencyContactModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor:
      theme.bottomSheetTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const EmergencyContactFormBottomSheet(),
    );

    if (result == null) return;

    final success = await widget.viewModel.addContact(result);
    if (!mounted) return;

    if (!success) {
      _showSnackBar(
        widget.viewModel.errorMessage == null
            ? context.tr('emergency_unexpected_error')
            : context.tr(widget.viewModel.errorMessage!),
      );
    }
  }

  Future<void> _openEditBottomSheet(EmergencyContactModel contact) async {
    final theme = Theme.of(context);
    final result = await showModalBottomSheet<EmergencyContactModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor:
      theme.bottomSheetTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => EmergencyContactFormBottomSheet(
        initialContact: contact,
      ),
    );

    if (result == null) return;

    final success = await widget.viewModel.updateContact(result);
    if (!mounted) return;

    if (!success) {
      _showSnackBar(
        widget.viewModel.errorMessage == null
            ? context.tr('emergency_unexpected_error')
            : context.tr(widget.viewModel.errorMessage!),
      );
    }
  }

  Future<void> _confirmDelete(EmergencyContactModel contact) async {
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        // This dialog title is localized for deleting an emergency contact.
        title: Text(context.tr('emergency_contact_delete_title')),
        // This dialog body is localized and injects the contact name.
        content: Text(
          context
              .tr('emergency_contact_delete_confirm')
              .replaceAll('{name}', contact.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.tr('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              context.tr('delete'),
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      ),
    ) ??
        false;

    if (!confirmed) return;

    await widget.viewModel.deleteContact(contact.localId!);
    if (!mounted) return;

    if (widget.viewModel.errorMessage != null) {
      _showSnackBar(context.tr(widget.viewModel.errorMessage!));
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
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
              // This screen title is localized for emergency contacts.
              context.tr('emergency_contacts_title'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openAddBottomSheet,
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            icon: const Icon(Icons.add),
            label: Text(
              // This FAB label is localized for adding a contact.
              context.tr('emergency_contact_add'),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          body: SafeArea(
            child: vm.isLoading
                ? Center(
              child: CircularProgressIndicator(
                color: colorScheme.primary,
              ),
            )
                : vm.contacts.isEmpty
                ? _EmptyContactsState(
              onAddPressed: _openAddBottomSheet,
            )
                : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              itemBuilder: (context, index) {
                final contact = vm.contacts[index];
                return _ContactManagementTile(
                  contact: contact,
                  onCallPressed: () async {
                    await vm.callContact(contact.phoneNumber);
                  },
                  onEditPressed: () async {
                    await _openEditBottomSheet(contact);
                  },
                  onDeletePressed: () async {
                    await _confirmDelete(contact);
                  },
                  onSetPrimaryPressed: contact.isPrimary
                      ? null
                      : () async {
                    await vm.setPrimaryContact(contact.localId!);
                  },
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: vm.contacts.length,
            ),
          ),
        );
      },
    );
  }
}

class _EmptyContactsState extends StatelessWidget {
  const _EmptyContactsState({
    required this.onAddPressed,
  });

  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: theme.dividerColor),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(
                  theme.brightness == Brightness.dark ? 0.08 : 0.04,
                ),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.people_outline_rounded,
                size: 56,
                color: colorScheme.onSurface.withOpacity(0.45),
              ),
              const SizedBox(height: 16),
              Text(
                // This empty state title is localized for emergency contacts.
                context.tr('emergency_contacts_empty_title'),
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                // This empty state subtitle is localized for emergency contacts.
                context.tr('emergency_contacts_empty_subtitle'),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.68),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: onAddPressed,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: Text(
                    // This button label is localized for adding an emergency contact.
                    context.tr('emergency_contact_add_single'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactManagementTile extends StatelessWidget {
  const _ContactManagementTile({
    required this.contact,
    required this.onCallPressed,
    required this.onEditPressed,
    required this.onDeletePressed,
    required this.onSetPrimaryPressed,
  });

  final EmergencyContactModel contact;
  final VoidCallback onCallPressed;
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback? onSetPrimaryPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(
                    theme.brightness == Brightness.dark ? 0.10 : 0.05,
                  ),
                  borderRadius: BorderRadius.circular(18),
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
                              fontSize: 17,
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
                                theme.brightness == Brightness.dark
                                    ? 0.16
                                    : 0.10,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              // This badge label is localized for a primary contact.
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
                onPressed: onCallPressed,
                icon: Icon(
                  Icons.call_rounded,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              if (!contact.isPrimary)
                Expanded(
                  child: OutlinedButton(
                    onPressed: onSetPrimaryPressed,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      side: BorderSide(color: colorScheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      // This button label is localized for setting a primary contact.
                      context.tr('emergency_contact_set_primary'),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              if (!contact.isPrimary) const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: onEditPressed,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.onSurface,
                    side: BorderSide(color: theme.dividerColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    context.tr('edit'),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: onDeletePressed,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    side: BorderSide(color: colorScheme.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    context.tr('delete'),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}