import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qudra_0/Feature/profile/widgets/LanguageSwitchTile.dart';
import 'package:qudra_0/core/Services/Localization/translation_extension.dart';
import '../../../core/Services/voiceAssistant/VoiceFab.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../Auth/ViewModel/auth_cubit.dart';
import '../../Auth/ViewModel/auth_state.dart';
import '../widgets/disability_profile_card.dart';
import '../widgets/profile_badge.dart';
import '../widgets/profile_logout_button.dart';
import '../widgets/profile_menu_item.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: const VoiceFAB(),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is AuthRestoring) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final authCubit = context.read<AuthCubit>();
            final user =
                authCubit.currentUser ?? (state is LoginSuccess ? state.user : null);

            if (user == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final fullName = user.fullName.trim().isEmpty
                ? context.tr("unknown")
                : user.fullName.trim();
            final disabilityType = user.disabilityType.trim();
            final initials = _extractInitials(fullName);
            final normalizedType = disabilityType.toLowerCase();
            final bool isVisual = normalizedType == 'visual';
            final bool isHearing = normalizedType == 'hearing';
            final bool isPhysical = normalizedType == 'physical';
            final bool isCognitive = normalizedType == 'cognitive';

            final profileAccent = isVisual
                ? const Color(0xFFF59E0B)
                : isHearing
                ? const Color(0xFF14B8A6)
                : isPhysical
                ? const Color(0xFFF97316)
                : isCognitive
                ? const Color(0xFFA855F7)
                : theme.colorScheme.primary;

            final profileBadgeLabel = isVisual
                ? context.tr("disability_visual")
                : isHearing
                ? context.tr("disability_hearing")
                : isPhysical
                ? context.tr("disability_physical")
                : isCognitive
                ? context.tr("disability_cognitive")
                : context.tr("disability_other");

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileHeroCard(
                    initials: initials,
                    fullName: fullName,
                    email: user.email,
                    profileBadgeLabel: profileBadgeLabel,
                    accentColor: profileAccent,
                  ),
                  const SizedBox(height: 18),
                  DisabilityProfileCard(
                    disabilityType: disabilityType,
                  ),
                  const SizedBox(height: 26),
                  _SectionBlock(
                    title: context.tr("account"),
                    child: Column(
                      children: [
                        ProfileMenuItem(
                          icon: Icons.person_outline_rounded,
                          title: context.tr("personal_info"),
                          subtitle: user.email,
                          iconColor: profileAccent,
                          iconBg: profileAccent.withOpacity(
                            theme.brightness == Brightness.dark ? 0.18 : 0.10,
                          ),
                          ontap: () => context.push('/personal'),
                        ),
                        const SizedBox(height: 12),
                        ProfileMenuItem(
                          icon: Icons.book_online_rounded,
                          title: context.tr("my_bookings"),
                          subtitle: context.tr("booking_result_title"),
                          iconColor: const Color(0xFF7C3AED),
                          iconBg: const Color(0xFF7C3AED).withOpacity(
                            theme.brightness == Brightness.dark ? 0.18 : 0.10,
                          ),
                          ontap: () => context.push('/my-bookings'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SectionBlock(
                    title: context.tr("support"),
                    child: Column(
                      children: [
                        ProfileMenuItem(
                          icon: Icons.menu_book_rounded,
                          title: context.tr("app_guidelines"),
                          subtitle: context.tr("app_guidelines_intro"),
                          iconColor: const Color(0xFF0F766E),
                          iconBg: const Color(0xFF14B8A6).withOpacity(
                            theme.brightness == Brightness.dark ? 0.18 : 0.10,
                          ),
                          ontap: () => context.push('/AppGuidelines'),
                        ),
                        const SizedBox(height: 12),
                        ProfileMenuItem(
                          icon: Icons.rate_review_outlined,
                          title: context.tr("feedback"),
                          subtitle: context.tr("guidelines_support_description"),
                          iconColor: const Color(0xFF2563EB),
                          iconBg: const Color(0xFF3B82F6).withOpacity(
                            theme.brightness == Brightness.dark ? 0.18 : 0.10,
                          ),
                          ontap: () => context.push('/feedback'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SectionBlock(
                    title: context.tr("appearance"),
                    child: BlocBuilder<ThemeCubit, ThemeMode>(
                      builder: (context, themeMode) {
                        return Column(
                          children: [
                            _SelectionTile<ThemeMode>(
                              title: context.tr("light_mode"),
                              icon: Icons.light_mode_rounded,
                              isSelected: themeMode == ThemeMode.light,
                              onTap: () => context.read<ThemeCubit>().setTheme(ThemeMode.light),
                            ),
                            const SizedBox(height: 10),
                            _SelectionTile<ThemeMode>(
                              title: context.tr("dark_mode"),
                              icon: Icons.dark_mode_rounded,
                              isSelected: themeMode == ThemeMode.dark,
                              onTap: () => context.read<ThemeCubit>().setTheme(ThemeMode.dark),
                            ),
                            const SizedBox(height: 10),
                            _SelectionTile<ThemeMode>(
                              title: context.tr("system_default"),
                              icon: Icons.settings_suggest_rounded,
                              isSelected: themeMode == ThemeMode.system,
                              onTap: () => context.read<ThemeCubit>().setTheme(ThemeMode.system),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SectionBlock(
                    title: context.tr("Language"),
                    child: const LanguageSwitchTile(),
                  ),
                  const SizedBox(height: 24),
                  const ProfileLogoutButton(),
                  const SizedBox(height: 22),
                  Center(
                    child: Text(
                      context.tr("app_slogan"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static String _extractInitials(String fullName) {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    final first = parts.first.substring(0, 1).toUpperCase();
    final last = parts.last.substring(0, 1).toUpperCase();
    return '$first$last';
  }
}

class _ProfileHeroCard extends StatelessWidget {
  final String initials;
  final String fullName;
  final String email;
  final String profileBadgeLabel;
  final Color accentColor;

  const _ProfileHeroCard({
    required this.initials,
    required this.fullName,
    required this.email,
    required this.profileBadgeLabel,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.dark ? 0.18 : 0.05,
            ),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accentColor.withOpacity(0.88),
                  accentColor,
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(
                    theme.brightness == Brightness.dark ? 0.28 : 0.18,
                  ),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            fullName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: theme.textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            email,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              ProfileBadge(
                icon: Icons.verified_rounded,
                text: context.tr("verified"),
                bgColor: accentColor.withOpacity(
                  theme.brightness == Brightness.dark ? 0.22 : 0.10,
                ),
                textColor: accentColor,
              ),
              ProfileBadge(
                icon: Icons.accessibility_new_rounded,
                text: profileBadgeLabel,
                bgColor: theme.scaffoldBackgroundColor,
                textColor: theme.textTheme.bodyLarge?.color ?? accentColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionBlock({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: theme.textTheme.titleLarge?.color,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: theme.dividerColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  theme.brightness == Brightness.dark ? 0.14 : 0.04,
                ),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }
}

class _SelectionTile<T> extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectionTile({
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