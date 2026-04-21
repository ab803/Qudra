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
          final visualData = _getChipVisualData(label);

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
  _ChipVisualData _getChipVisualData(String chipLabel) {
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
        return const _ChipVisualData(
          icon: Icons.dashboard_customize_rounded,
          accentColor: Colors.black87,
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
    final backgroundColor = isSelected ? Colors.black : Colors.white;
    final textColor = isSelected ? Colors.white : Colors.black87;
    final iconColor = isSelected ? Colors.white : accentColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          constraints: const BoxConstraints(minHeight: 46),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected
                  ? Colors.black
                  : Colors.black.withOpacity(0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  isSelected ? 0.10 : 0.04,
                ),
                blurRadius: isSelected ? 14 : 10,
                offset: const Offset(0, 4),
              ),
            ],
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