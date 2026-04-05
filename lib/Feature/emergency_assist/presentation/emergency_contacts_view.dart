import 'package:flutter/material.dart';

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
    final result = await showModalBottomSheet<EmergencyContactModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const EmergencyContactFormBottomSheet(),
    );

    if (result == null) return;

    final success = await widget.viewModel.addContact(result);
    if (!mounted) return;

    if (!success) {
      _showSnackBar(widget.viewModel.errorMessage ?? 'حدث خطأ غير متوقع.');
    }
  }

  Future<void> _openEditBottomSheet(EmergencyContactModel contact) async {
    final result = await showModalBottomSheet<EmergencyContactModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
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
      _showSnackBar(widget.viewModel.errorMessage ?? 'حدث خطأ غير متوقع.');
    }
  }

  Future<void> _confirmDelete(EmergencyContactModel contact) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('حذف جهة الاتصال'),
          content: Text(
            'هل تريد حذف "${contact.name}" من جهات اتصال الطوارئ؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'حذف',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    ) ??
        false;

    if (!confirmed) return;

    await widget.viewModel.deleteContact(contact.localId!);
    if (!mounted) return;

    if (widget.viewModel.errorMessage != null) {
      _showSnackBar(widget.viewModel.errorMessage!);
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
                'جهات اتصال الطوارئ',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: _openAddBottomSheet,
              backgroundColor: const Color(0xFF0D6EFD),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text(
                'إضافة جهة',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            body: SafeArea(
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
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
                      await vm.setPrimaryContact(
                        contact.localId!,
                      );
                    },
                  );
                },
                separatorBuilder: (_, __) =>
                const SizedBox(height: 12),
                itemCount: vm.contacts.length,
              ),
            ),
          );
        },
      ),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.people_outline_rounded,
                size: 56,
                color: Color(0xFF9CA3AF),
              ),
              const SizedBox(height: 16),
              const Text(
                'لا توجد جهات اتصال للطوارئ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'أضف أشخاصًا موثوقين مثل أحد الوالدين أو مقدم رعاية أو طبيب ليظهروا في الشاشة الرئيسية وفي بطاقة الطوارئ.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF6B7280),
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
                    backgroundColor: const Color(0xFF0D6EFD),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'إضافة جهة اتصال',
                    style: TextStyle(
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(18),
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
                onPressed: onCallPressed,
                icon: const Icon(
                  Icons.call_rounded,
                  color: Color(0xFF0D6EFD),
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
                      foregroundColor: const Color(0xFF0D6EFD),
                      side: const BorderSide(color: Color(0xFF0D6EFD)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'تعيين كأساسي',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              if (!contact.isPrimary) const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: onEditPressed,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF111827),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'تعديل',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: onDeletePressed,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'حذف',
                    style: TextStyle(fontWeight: FontWeight.w800),
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