import 'package:flutter/material.dart';
import 'package:qudra_0/core/Services/Localization/translation_extension.dart';
import 'package:qudra_0/core/Styles/AppColors.dart';

class InstitutionFilterBar extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  const InstitutionFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  // English keys — stored as selectedFilter values, never change.
  static const List<String> _filterKeys = [
    'All', 'Mobility', 'Vision', 'Hearing', 'Cognitive', 'Other',
  ];

  // Maps each key to its translation key.
  static const Map<String, String> _translationKeys = {
    'All':      'filter_all',
    'Mobility': 'filter_mobility',
    'Vision':   'filter_vision',
    'Hearing':  'filter_hearing',
    'Cognitive':'filter_cognitive',
    'Other':    'filter_other',
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(_filterKeys.length, (index) {
          final key = _filterKeys[index];
          final label = context.tr(_translationKeys[key]!);
          final visualData = _getChipVisualData(key, context);

          return Padding(
            padding: EdgeInsets.only(
              right: index == _filterKeys.length - 1 ? 0 : 10,
            ),
            child: _InstitutionFilterChip(
              label: label,
              icon: visualData.icon,
              accentColor: visualData.accentColor,
              isSelected: selectedFilter == key,
              onTap: () => onFilterSelected(key), // always pass the English key
            ),
          );
        }),
      ),
    );
  }

  _ChipVisualData _getChipVisualData(String key, BuildContext context) {
    switch (key) {
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
    final backgroundColor = isSelected ? colorScheme.onSurface : theme.cardColor;
    final textColor = isSelected ? colorScheme.surface : colorScheme.onSurface;
    final iconColor = isSelected ? colorScheme.surface : accentColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          constraints: const BoxConstraints(minHeight: 46),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? colorScheme.onSurface : theme.dividerColor,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(
                  isSelected
                      ? (isDark ? 0.30 : 0.10)
                      : (isDark ? 0.18 : 0.05),
                ),
                blurRadius: isSelected ? 14 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: iconColor),
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
    );
  }
}

class _ChipVisualData {
  final IconData icon;
  final Color accentColor;
  const _ChipVisualData({required this.icon, required this.accentColor});
}