import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../feedback/widgets/institution_rating_summary.dart';
import '../../feedback/widgets/rate_institution_dialog.dart';
import '../viewmodel/institution_cubit.dart';
import '../viewmodel/institution_state.dart';
import '../widgets/service_tile.dart';

class InstitutionDetailsView extends StatefulWidget {
  final String institutionId;

  const InstitutionDetailsView({
    super.key,
    required this.institutionId,
  });

  @override
  State<InstitutionDetailsView> createState() =>
      _InstitutionDetailsViewState();
}

class _InstitutionDetailsViewState extends State<InstitutionDetailsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<InstitutionCubit>()
          .loadInstitutionDetails(widget.institutionId);
    });
  }

  Future<void> _openRateInstitutionDialog({
    required String institutionId,
    required String institutionName,
  }) async {
    final didSubmit = await showDialog<bool>(
      context: context,
      builder: (_) => RateInstitutionDialog(
        institutionId: institutionId,
        institutionName: institutionName,
      ),
    );

    if (didSubmit == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Institution rating submitted successfully.'),
        ),
      );
      setState(() {
        // Rebuild to refresh rating summary
      });
    }
  }

  // This method opens the institution location link in an external maps app.
  Future<void> _openLocationLink(String locationUrl) async {
    final uri = Uri.parse(locationUrl);
    final didLaunch = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!didLaunch && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open the location link.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Institution Details',
          style: theme.textTheme.titleLarge,
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<InstitutionCubit, InstitutionState>(
          builder: (context, state) {
            if (state is InstitutionLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is InstitutionError) {
              return Center(
                child: Text(
                  state.errorMessage,
                  style: theme.textTheme.bodyMedium,
                ),
              );
            }

            if (state is InstitutionDetailsLoaded) {
              final institution = state.institution;
              final services = state.services;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: theme.dividerColor),
                        boxShadow: [
                          BoxShadow(
                            color:
                            theme.shadowColor.withOpacity(isDark ? 0.30 : 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color:
                              colorScheme.onSurface.withOpacity(isDark ? 0.08 : 0.05),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.business,
                              size: 28,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  institution.name,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  institution.institutionType,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    if ((institution.description ?? '').trim().isNotEmpty) ...[
                      Text(
                        'About',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        institution.description!.trim(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ] else ...[
                      Text(
                        'About',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No institution description available yet.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Rating + button (unchanged)
                    Row(
                      children: [
                        Expanded(
                          child: InstitutionRatingSummary(
                            key: ValueKey(
                              'institution-summary-${institution.id}',
                            ),
                            institutionId: institution.id,
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            _openRateInstitutionDialog(
                              institutionId: institution.id,
                              institutionName: institution.name,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            'Rate Institution',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _InfoRow(
                      label: 'Address',
                      value: institution.address ?? 'Not provided',
                    ),
                    _InfoRow(
                      label: 'Location',
                      value: 'Open in Maps',
                      isAction: true,
                      onTap: () => _openLocationLink(institution.location),
                    ),
                    _InfoRow(
                      label: 'Phone',
                      value: institution.phone ?? 'Not provided',
                    ),
                    _InfoRow(
                      label: 'Email',
                      value: institution.email,
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Services',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (services.isEmpty)
                      Text(
                        'No active services available right now',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ...services.map(
                          (service) => ServiceTile(
                        service: service,
                        onBookNow: () {
                          context.push(
                            '/booking/checkout',
                            extra: {
                              'institution': institution,
                              'service': service,
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isAction;
  final VoidCallback? onTap;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isAction = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: isAction
                ? InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      value,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.open_in_new_rounded,
                      size: 15,
                      color: theme.textTheme.bodySmall?.color?.withOpacity(
                        isDark ? 0.9 : 1,
                      ),
                    ),
                  ],
                ),
              ),
            )
                : Text(
              value,
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}