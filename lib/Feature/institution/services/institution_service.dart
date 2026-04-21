import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/institution_model.dart';
import '../models/service_model.dart';

class InstitutionFeatureService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // This constant defines which institutions are visible in the user app.
  static const String _activeInstitutionStatus = 'active';

  // Load all visible institutions from Supabase
  Future<List<InstitutionModel>> fetchInstitutions() async {
    // This query returns only active institutions for the user app.
    final result = await _supabase
        .from('institutions')
        .select()
        .eq('status', _activeInstitutionStatus)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(result)
        .map(InstitutionModel.fromJson)
        .toList();
  }

  // This method builds a supported disabilities map for each institution
  // using active services only.
  Future<Map<String, List<String>>> fetchInstitutionDisabilityMap() async {
    final result = await _supabase
        .from('services')
        .select('institution_id, supported_disabilities')
        .eq('is_active', true);

    final disabilityMap = <String, Set<String>>{};

    for (final row in List<Map<String, dynamic>>.from(result)) {
      final institutionId = row['institution_id'] as String?;
      if (institutionId == null) {
        continue;
      }

      final supportedDisabilities =
      (row['supported_disabilities'] as List<dynamic>? ?? [])
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty);

      disabilityMap.putIfAbsent(institutionId, () => <String>{});
      disabilityMap[institutionId]!.addAll(supportedDisabilities);
    }

    return disabilityMap.map(
          (key, value) => MapEntry(key, value.toList()),
    );
  }

  // Load one visible institution by id
  Future<InstitutionModel> fetchInstitutionById(String institutionId) async {
    // This query prevents loading non-active institutions in the user app.
    final result = await _supabase
        .from('institutions')
        .select()
        .eq('id', institutionId)
        .eq('status', _activeInstitutionStatus)
        .single();

    return InstitutionModel.fromJson(result);
  }

  // Load all active services for one institution
  Future<List<InstitutionServiceModel>> fetchInstitutionServices(
      String institutionId,
      ) async {
    // Debug current institution id being requested
    print('Fetching services for institution: $institutionId');

    final result = await _supabase
        .from('services')
        .select()
        .eq('institution_id', institutionId)
        .eq('is_active', true)
        .order('created_at', ascending: false);

    // Debug raw services result from Supabase
    print('Raw services result: $result');

    return List<Map<String, dynamic>>.from(result)
        .map(InstitutionServiceModel.fromJson)
        .toList();
  }

  // This method calculates a simple recommendation score for each institution.
  int _calculateRecommendationScore({
    required List<InstitutionServiceModel> matchingServices,
    required List<InstitutionServiceModel> allActiveServices,
  }) {
    final freeMatchingServicesCount =
        matchingServices.where((service) => service.isFree).length;

    return (matchingServices.length * 100) +
        (allActiveServices.length * 10) +
        (freeMatchingServicesCount * 5);
  }

  // This method groups services by their institution id for faster recommendation scoring.
  Map<String, List<InstitutionServiceModel>> _groupServicesByInstitution(
      List<InstitutionServiceModel> services,
      ) {
    final groupedServices = <String, List<InstitutionServiceModel>>{};

    for (final service in services) {
      groupedServices.putIfAbsent(service.institutionId, () => []);
      groupedServices[service.institutionId]!.add(service);
    }

    return groupedServices;
  }

  // Load recommended institutions based on disability type
  Future<List<InstitutionModel>> fetchRecommendedInstitutions({
    required String disabilityType,
    int limit = 5,
  }) async {
    // This block loads all active services that can participate in recommendations.
    final serviceRows = await _supabase
        .from('services')
        .select()
        .eq('is_active', true);

    final allActiveServices = List<Map<String, dynamic>>.from(serviceRows)
        .map(InstitutionServiceModel.fromJson)
        .toList();

    // This block filters services that directly match the current user's disability type.
    final matchingServices = allActiveServices.where((service) {
      return service.supportedDisabilities.contains(disabilityType);
    }).toList();

    // Fallback: if nothing matches, return latest active institutions
    if (matchingServices.isEmpty) {
      final institutions = await fetchInstitutions();
      return institutions.take(limit).toList();
    }

    // This block groups services to calculate recommendation scores per institution.
    final allServicesByInstitution =
    _groupServicesByInstitution(allActiveServices);
    final matchingServicesByInstitution =
    _groupServicesByInstitution(matchingServices);

    final matchingInstitutionIds = matchingServicesByInstitution.keys.toList();

    // This query loads only active institutions that have matching services.
    final institutionsResult = await _supabase
        .from('institutions')
        .select()
        .inFilter('id', matchingInstitutionIds)
        .eq('status', _activeInstitutionStatus);

    final institutions = List<Map<String, dynamic>>.from(institutionsResult)
        .map(InstitutionModel.fromJson)
        .toList();

    // This block assigns a score to each institution and sorts them from best to worst.
    final scoredInstitutions = institutions.map((institution) {
      final institutionMatchingServices =
          matchingServicesByInstitution[institution.id] ?? [];
      final institutionAllServices =
          allServicesByInstitution[institution.id] ?? [];

      final score = _calculateRecommendationScore(
        matchingServices: institutionMatchingServices,
        allActiveServices: institutionAllServices,
      );

      return _InstitutionRecommendationScore(
        institution: institution,
        score: score,
      );
    }).toList();

    scoredInstitutions.sort((a, b) {
      final scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) {
        return scoreCompare;
      }

      final aCreatedAt =
          a.institution.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bCreatedAt =
          b.institution.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

      return bCreatedAt.compareTo(aCreatedAt);
    });

    final rankedInstitutions = scoredInstitutions
        .map((item) => item.institution)
        .toList();

    // This block fills any remaining slots with the latest active institutions.
    if (rankedInstitutions.length >= limit) {
      return rankedInstitutions.take(limit).toList();
    }

    final fallbackInstitutions = await fetchInstitutions();
    final rankedInstitutionIds =
    rankedInstitutions.map((institution) => institution.id).toSet();

    final remainingInstitutions = fallbackInstitutions.where((institution) {
      return !rankedInstitutionIds.contains(institution.id);
    }).toList();

    return [
      ...rankedInstitutions,
      ...remainingInstitutions,
    ].take(limit).toList();
  }
}

// This helper model stores the calculated recommendation score for sorting.
class _InstitutionRecommendationScore {
  final InstitutionModel institution;
  final int score;

  const _InstitutionRecommendationScore({
    required this.institution,
    required this.score,
  });
}