import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/Styles/AppTextsyles.dart';
import '../../../../core/Utilies/getit.dart';
import '../../../Auth/ViewModel/auth_cubit.dart';
import '../../../Auth/ViewModel/auth_state.dart';
import '../../../institution/models/institution_model.dart';
import '../../../institution/services/institution_service.dart';
import '../../../institution/widgets/institutionCard.dart';

class RecommendedSection extends StatefulWidget {
  const RecommendedSection({super.key});

  @override
  State<RecommendedSection> createState() => _RecommendedSectionState();
}

class _RecommendedSectionState extends State<RecommendedSection> {
  Future<List<InstitutionModel>>? _future;
  String? _loadedDisabilityType;

  // This controller enables a snapping carousel-style PageView for home recommendations.
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.94);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _ensureRecommendationsLoaded(String disabilityType) {
    if (_future != null && _loadedDisabilityType == disabilityType) {
      return;
    }

    _future = getIt<InstitutionFeatureService>().fetchRecommendedInstitutions(
      disabilityType: disabilityType,
      limit: 5,
    );
    _loadedDisabilityType = disabilityType;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // This block defines a compact home-only viewport height that matches the compact card design.
    const double recommendedCardHeight = 252;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommended For You',
          style: AppTextStyles.subtitle.copyWith(
            color: theme.textTheme.titleMedium?.color,
          ),
        ),
        const SizedBox(height: 16),
        BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final authCubit = context.read<AuthCubit>();
            final user =
                authCubit.currentUser ?? (state is LoginSuccess ? state.user : null);

            if (user == null) {
              if (state is AuthRestoring || state is AuthLoading) {
                return const SizedBox(
                  height: recommendedCardHeight,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              return SizedBox(
                height: recommendedCardHeight,
                child: Center(
                  child: Text(
                    'No recommendations available right now',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              );
            }

            _ensureRecommendationsLoaded(user.disabilityType);

            return SizedBox(
              height: recommendedCardHeight,
              child: FutureBuilder<List<InstitutionModel>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        snapshot.error.toString(),
                        style: theme.textTheme.bodySmall,
                      ),
                    );
                  }

                  final institutions = snapshot.data ?? [];
                  if (institutions.isEmpty) {
                    return Center(
                      child: Text(
                        'No recommendations available right now',
                        style: theme.textTheme.bodyMedium,
                      ),
                    );
                  }

                  // This block replaces the horizontal list with a snapping PageView for a cleaner professional layout.
                  return PageView.builder(
                    controller: _pageController,
                    itemCount: institutions.length,
                    itemBuilder: (context, index) {
                      final institution = institutions[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          right: index == institutions.length - 1 ? 0 : 12,
                        ),
                        child: InstitutionCard(
                          institution: institution,
                          isCompact: true,
                          onViewDetails: () {
                            context.push('/institution/${institution.id}');
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}