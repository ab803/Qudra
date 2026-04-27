import 'package:flutter/material.dart';
import 'package:qudra_0/core/Styles/AppColors.dart';

// This widget renders the institutions disability filter chips row.
class InstitutionFilterBar extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  const InstitutionFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    const filterLabels = ['All', 'Mobility', 'Vision', 'Hearing'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(filterLabels.length, (index) {
          final label = filterLabels[index];
          final visualData = _getChipVisualData(label, context);

          return Padding(
            padding: EdgeInsets.only(
              right: index == filterLabels.length - 1 ? 0 : 10,
            ),
            child: _InstitutionFilterChip(
              label: label,
              icon: visualData.icon,
              accentColor: visualData.accentColor,
              isSelected: selectedFilter == label,
              onTap: () => onFilterSelected(label),
            ),
          );
        }),
      ),
    );
  }

  // This method returns the visual style config for each filter chip.
  _ChipVisualData _getChipVisualData(String chipLabel, BuildContext context) {
    switch (chipLabel) {
      case 'Mobility':
        return const _ChipVisualData(
          icon: Icons.accessible_rounded,
          accentColor: Appcolors.cardOrange,
        );
      case 'Vision':
        return const _ChipVisualData(
          icon: Icons.visibility_rounded,
          accentColor: Appcolors.rateColor,
        );
      case 'Hearing':
        return const _ChipVisualData(
          icon: Icons.hearing_rounded,
          accentColor: Appcolors.cardTeal,
        );
      default:
        return _ChipVisualData(
          icon: Icons.dashboard_customize_rounded,
          accentColor: Theme.of(context).colorScheme.onSurface,
        );
    }
  }
}

// This widget renders a single filter chip with icon and label.
class _InstitutionFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color accentColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _InstitutionFilterChip({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isAllChip = label == 'All';

    final Color backgroundColor = isSelected
        ? (isAllChip ? accentColor : accentColor)
        : theme.cardColor;

    final Color textColor = isSelected
        ? (isAllChip ? colorScheme.onPrimary : colorScheme.onPrimary)
        : colorScheme.onSurface;

    final Color iconColor = isSelected
        ? (isAllChip ? colorScheme.onPrimary : colorScheme.onPrimary)
        : accentColor;

    final Color borderColor = isSelected
        ? (isAllChip ? theme.dividerColor : accentColor)
        : theme.dividerColor;

    final Color shadowColor = isSelected
        ? (isAllChip ? Colors.black : accentColor)
        : theme.shadowColor;

    return AnimatedScale(
      scale: isSelected ? 1.02 : 1.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withOpacity(
                isSelected
                    ? (isAllChip
                    ? (isDark ? 0.18 : 0.08)
                    : (isDark ? 0.30 : 0.14))
                    : (isDark ? 0.16 : 0.04),
              ),
              blurRadius: isSelected ? 14 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: onTap,
            splashColor: accentColor.withOpacity(0.10),
            highlightColor: accentColor.withOpacity(0.06),
            child: Container(
              constraints: const BoxConstraints(minHeight: 46),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 11,
              ),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: iconColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// This helper model stores the icon and accent color for each filter chip.
class _ChipVisualData {
  final IconData icon;
  final Color accentColor;

  const _ChipVisualData({
    required this.icon,
    required this.accentColor,
  });
}