import 'package:flutter/material.dart';

class PermissionEmptyStatesView extends StatelessWidget {
  const PermissionEmptyStatesView({
    super.key,
    required this.isLoading,
    required this.onEnableLocationPressed,
    required this.onSkipPressed,
    this.onOpenLocationSettingsPressed,
    this.helperMessage,
    this.showOpenLocationSettingsButton = false,
  });

  final bool isLoading;
  final VoidCallback onEnableLocationPressed;
  final VoidCallback onSkipPressed;
  final VoidCallback? onOpenLocationSettingsPressed;
  final String? helperMessage;
  final bool showOpenLocationSettingsButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'قدرة',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.72),
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(32),
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
                    children: [
                      Container(
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(
                          color: colorScheme.error.withOpacity(
                            theme.brightness == Brightness.dark ? 0.14 : 0.08,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.location_off_rounded,
                          color: colorScheme.error,
                          size: 42,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'صلاحية الموقع غير\nمفعلة',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'نحتاج للوصول لموقعك الجغرافي للتمكن من مشاركته مع جهات اتصالك في حالة الطوارئ.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.72),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                if (helperMessage != null && helperMessage!.trim().isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(
                        theme.brightness == Brightness.dark ? 0.14 : 0.08,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: colorScheme.primary.withOpacity(0.20),
                      ),
                    ),
                    child: Text(
                      helperMessage!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : onEnableLocationPressed,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    icon: isLoading
                        ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                        : const Icon(Icons.navigation_rounded),
                    label: Text(
                      isLoading ? 'جاري التفعيل...' : 'تفعيل صلاحية الموقع',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                if (showOpenLocationSettingsButton &&
                    onOpenLocationSettingsPressed != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed:
                      isLoading ? null : onOpenLocationSettingsPressed,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                        side: BorderSide(color: colorScheme.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: const Icon(Icons.location_on_outlined),
                      label: const Text(
                        'فتح إعدادات الموقع',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                TextButton(
                  onPressed: isLoading ? null : onSkipPressed,
                  child: Text(
                    'تخطي الآن',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}