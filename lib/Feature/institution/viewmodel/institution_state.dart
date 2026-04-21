import '../models/institution_model.dart';
import '../models/service_model.dart';

abstract class InstitutionState {}

class InstitutionInitial extends InstitutionState {}

class InstitutionLoading extends InstitutionState {}

class InstitutionsLoaded extends InstitutionState {
  final List<InstitutionModel> institutions;
  final Map<String, List<String>> supportedDisabilitiesByInstitution;

  InstitutionsLoaded({
    required this.institutions,
    required this.supportedDisabilitiesByInstitution,
  });
}

class InstitutionDetailsLoaded extends InstitutionState {
  final InstitutionModel institution;
  final List<InstitutionServiceModel> services;

  InstitutionDetailsLoaded({
    required this.institution,
    required this.services,
  });
}

class InstitutionError extends InstitutionState {
  final String errorMessage;

  InstitutionError({required this.errorMessage});
}