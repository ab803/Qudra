import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/Services/Localization/language_cubit.dart';
import '../../../core/Services/Localization/language_state.dart';

class LanguageSwitchTile extends StatelessWidget {
  const LanguageSwitchTile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.dark ? 0.14 : 0.03,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BlocBuilder<LanguageCubit, LanguageState>(
        builder: (context, state) {
          final locale = state.locale.languageCode;

          return Column(
            children: [
              RadioListTile<String>(
                title: Text(
                  "English",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                value: 'en',
                groupValue: locale,
                activeColor: theme.colorScheme.primary,
                onChanged: (value) {
                  if (value != null) {
                    context.read<LanguageCubit>().changeLanguage(value);
                  }
                },
              ),

              Divider(color: theme.dividerColor),

              RadioListTile<String>(
                title: Text(
                  "العربية",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                value: 'ar',
                groupValue: locale,
                activeColor: theme.colorScheme.primary,
                onChanged: (value) {
                  if (value != null) {
                    context.read<LanguageCubit>().changeLanguage(value);
                  }
                },
              ),

              Divider(color: theme.dividerColor),

              RadioListTile<String>(
                title: Text(
                  "System Default",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                value: 'system',
                groupValue: locale,
                activeColor: theme.colorScheme.primary,
                onChanged: (value) {
                  if (value != null) {
                    context.read<LanguageCubit>().changeLanguage(value);
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}