import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/institution_service.dart';
import 'institution_state.dart';

class InstitutionCubit extends Cubit<InstitutionState> {
  final InstitutionFeatureService _institutionService;

  InstitutionCubit(this._institutionService) : super(InstitutionInitial());

  // Load institutions list for user app
  Future<void> loadInstitutions() async {
    emit(InstitutionLoading());

    try {
      // This block loads institutions and their supported disabilities map together.
      final institutionsFuture = _institutionService.fetchInstitutions();
      final disabilityMapFuture =
      _institutionService.fetchInstitutionDisabilityMap();

      final institutions = await institutionsFuture;
      final disabilityMap = await disabilityMapFuture;

      emit(
        InstitutionsLoaded(
          institutions: institutions,
          supportedDisabilitiesByInstitution: disabilityMap,
        ),
      );
    } catch (e) {
      emit(InstitutionError(errorMessage: e.toString()));
    }
  }

  // Load institution details and its services
  Future<void> loadInstitutionDetails(String institutionId) async {
    emit(InstitutionLoading());

    try {
      final institution =
      await _institutionService.fetchInstitutionById(institutionId);
      final services =
      await _institutionService.fetchInstitutionServices(institutionId);

      emit(
        InstitutionDetailsLoaded(
          institution: institution,
          services: services,
        ),
      );
    } catch (e) {
      emit(InstitutionError(errorMessage: e.toString()));
    }
  }
}