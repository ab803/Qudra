import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/Styles/AppColors.dart';
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

  // This method reloads recommendations only when the user's disability type becomes available or changes.
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
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth > 420 ? 360.0 : screenWidth * 0.88;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommended For You',
          style: AppTextStyles.subtitle.copyWith(
            color: Appcolors.primaryColor,
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
                  height: 220,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              return const SizedBox(
                height: 220,
                child: Center(
                  child: Text(
                    'No recommendations available right now',
                  ),
                ),
              );
            }

            // This block ensures recommendations are loaded only after the real user profile becomes available.
            _ensureRecommendationsLoaded(user.disabilityType);

            return SizedBox(
              height: 220,
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
                      child: Text(snapshot.error.toString()),
                    );
                  }

                  final institutions = snapshot.data ?? [];
                  if (institutions.isEmpty) {
                    return const Center(
                      child: Text(
                        'No recommendations available right now',
                      ),
                    );
                  }

                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: institutions.length,
                    separatorBuilder: (context, index) =>
                    const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final institution = institutions[index];
                      return SizedBox(
                        width: cardWidth,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: InstitutionCard(
                            institution: institution,
                            onViewDetails: () {
                              context.push('/institution/${institution.id}');
                            },
                          ),
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