import '../../../core/Models/people_with_disabilityModel.dart';

abstract class IPeopleWithDisabilityRepository {
  // ─────────────────────────────────────────
  // AUTH
  // ─────────────────────────────────────────
  Future<PeopleWithDisabilityModel> register({
    required String fullName,
    required String phone,
    required String email,
    required String password,
    required String disabilityType,
    required String responsiblePerson,
    required String gender,
    required int age,
  });

  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  });

  // This method checks whether the email already exists in the user app table.
  Future<bool> isEmailRegistered(String email);

  // ─────────────────────────────────────────
  // PROFILE
  // ─────────────────────────────────────────
  Future<PeopleWithDisabilityModel?> getCurrentProfile();
  Future<PeopleWithDisabilityModel> getById(String id);
  Future<List<PeopleWithDisabilityModel>> getAll();

  Future<void> updateProfile({
    required String id,
    String? fullName,
    String? phone, // ✅ fixed: was int? — must match model (String)
    String? disabilityType,
    String? responsiblePerson,
    String? gender,
    int? age,
  });

  Future<void> delete(String id);
}