import 'package:flutter/material.dart';

// This widget renders a selectable payment method tile for the booking payment method screen.
class BookingPaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const BookingPaymentMethodTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? colorScheme.primary : theme.dividerColor,
            width: selected ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(isDark ? 0.22 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // This block shows the payment method icon.
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withOpacity(isDark ? 0.08 : 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: colorScheme.onSurface),
            ),
            const SizedBox(width: 14),

            // This block shows the payment method title and description.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // This block shows the selection indicator on the right side.
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? colorScheme.primary : theme.dividerColor,
                  width: 2,
                ),
                color: selected ? colorScheme.primary : theme.cardColor,
              ),
              child: selected
                  ? Icon(Icons.circle, size: 9, color: colorScheme.onPrimary)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}