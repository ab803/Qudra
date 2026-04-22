import 'package:flutter/material.dart';

import '../models/emergency_contact_model.dart';

class EmergencyCircleSection extends StatelessWidget {
  const EmergencyCircleSection({
    super.key,
    required this.contacts,
    required this.onAddContactsPressed,
    required this.onCallContactPressed,
  });

  final List<EmergencyContactModel> contacts;
  final VoidCallback onAddContactsPressed;
  final ValueChanged<String> onCallContactPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final previewContacts = contacts.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'دائرة الطوارئ',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton(
              onPressed: onAddContactsPressed,
              child: Text(
                contacts.isEmpty ? 'إضافة' : 'إدارة',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (contacts.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.people_outline_rounded,
                  size: 36,
                  color: colorScheme.onSurface.withOpacity(0.45),
                ),
                const SizedBox(height: 12),
                Text(
                  'لا توجد جهات اتصال للطوارئ حتى الآن',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'أضف أشخاصًا موثوقين مثل أحد الوالدين أو مقدم رعاية أو طبيب.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.68),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: onAddContactsPressed,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text(
                      'إضافة جهات الاتصال',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: previewContacts.map((contact) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ContactTile(
                  name: contact.name,
                  relation: contact.relation,
                  isPrimary: contact.isPrimary,
                  onCallPressed: () =>
                      onCallContactPressed(contact.phoneNumber),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.name,
    required this.relation,
    required this.isPrimary,
    required this.onCallPressed,
  });

  final String name;
  final String relation;
  final bool isPrimary;
  final VoidCallback onCallPressed;

  @override
  Widget build(BuildContext context) {
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
                    Text(
                      name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (isPrimary) ...[
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
                  relation,
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
            onPressed: onCallPressed,
            icon: Icon(
              Icons.call_rounded,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

