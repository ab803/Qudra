import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qudra_0/core/Services/Localization/translation_extension.dart';
import '../../../core/Services/Localization/language_cubit.dart';
import '../../../core/Services/Localization/language_state.dart';

class LanguageSwitchTile extends StatelessWidget {
  const LanguageSwitchTile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, state) {
        final locale = state.locale.languageCode;

        return Column(
          children: [
            _LanguageOptionTile(
              title: context.tr("language_english"),
              icon: Icons.language_rounded,
              isSelected: locale == 'en',
              onTap: () => context.read<LanguageCubit>().changeLanguage('en'),
            ),
            const SizedBox(height: 10),
            _LanguageOptionTile(
              title: context.tr("language_arabic"),
              icon: Icons.translate_rounded,
              isSelected: locale == 'ar',
              onTap: () => context.read<LanguageCubit>().changeLanguage('ar'),
            ),
            const SizedBox(height: 10),
            _LanguageOptionTile(
              title: context.tr("system_default"),
              icon: Icons.settings_suggest_rounded,
              isSelected: false,
              onTap: () => context.read<LanguageCubit>().changeLanguage('system'),
            ),
          ],
        );
      },
    );
  }
}

class _LanguageOptionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOptionTile({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(
              theme.brightness == Brightness.dark ? 0.18 : 0.08,
            )
                : theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.dividerColor,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.cardColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: 18,
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.dividerColor,
                  ),
                ),
                child: isSelected
                    ? Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: theme.colorScheme.onPrimary,
                )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}