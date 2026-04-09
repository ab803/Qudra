import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/people_with_disability_model.dart';

abstract class IPeopleWithDisabilityRepository {
  Future<PeopleWithDisabilityModel> register({
    required String fullName,
    required int phone,
    required String email,
    required String password,
    required String disabilityType,
    required String responsiblePerson,
    required String gender,
    required int age,
  });

  Future<PeopleWithDisabilityModel?> getCurrentProfile();
  Future<PeopleWithDisabilityModel> getById(String id);
  Future<List<PeopleWithDisabilityModel>> getAll();
  Future<void> updateProfile({
    required String id,
    String? fullName,
    int? phone,
    String? disabilityType,
    String? responsiblePerson,
    String? gender,
    int? age,
  });
  Future<void> delete(String id);
}