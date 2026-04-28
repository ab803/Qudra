import 'package:qudra_0/core/Services/supabase/AuthService.dart';
import '../../../core/Models/people_with_disabilityModel.dart';
import '../../../core/Services/supabase/peopleWithDisabilityService.dart';
import 'AuthRepo.dart';

class PeopleWithDisabilityRepositoryImpl
    implements IPeopleWithDisabilityRepository {
  final PeopleWithDisabilityService _service;
  final AuthService reset;

  PeopleWithDisabilityRepositoryImpl({
    required PeopleWithDisabilityService service,
    required this.reset,
  }) : _service = service;

  // ─────────────────────────────────────────
  // REGISTER
  // ─────────────────────────────────────────
  @override
  Future<PeopleWithDisabilityModel> register({
    required String fullName,
    required String phone,
    required String email,
    required String password,
    required String disabilityType,
    required String responsiblePerson,
    required String gender,
    required int age,
  }) async {
    return await _service.register(
      fullName: fullName,
      phone: phone,
      email: email,
      password: password,
      disabilityType: disabilityType,
      responsiblePerson: responsiblePerson,
      gender: gender,
      age: age,
    );
  }

  // ─────────────────────────────────────────
  // RESET PASSWORD
  // ─────────────────────────────────────────
  @override
  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    await reset.resetPassword(
      email: email,
      token: token,
      newPassword: newPassword,
    );
  }

  // This method checks whether the email already exists in the user app table.
  @override
  Future<bool> isEmailRegistered(String email) async {
    return await _service.isEmailRegistered(email);
  }

  // ─────────────────────────────────────────
  // GET CURRENT PROFILE
  // ─────────────────────────────────────────
  @override
  Future<PeopleWithDisabilityModel?> getCurrentProfile() async {
    return await _service.getCurrentProfile();
  }

  // ─────────────────────────────────────────
  // GET BY ID
  // ─────────────────────────────────────────
  @override
  Future<PeopleWithDisabilityModel> getById(String id) async {
    return await _service.getById(id);
  }

  // ─────────────────────────────────────────
  // GET ALL
  // ─────────────────────────────────────────
  @override
  Future<List<PeopleWithDisabilityModel>> getAll() async {
    return await _service.getAll();
  }

  // ─────────────────────────────────────────
  // UPDATE PROFILE
  // ─────────────────────────────────────────
  @override
  Future<void> updateProfile({
    required String id,
    String? fullName,
    String? phone, // ✅ fixed: was int? — must match model (String)
    String? disabilityType,
    String? responsiblePerson,
    String? gender,
    int? age,
  }) async {
    await _service.updateProfile(
      id: id,
      fullName: fullName,
      phone: phone,
      disabilityType: disabilityType,
      responsiblePerson: responsiblePerson,
      gender: gender,
      age: age,
    );
  }

  // ─────────────────────────────────────────
  // DELETE
  // ─────────────────────────────────────────
  @override
  Future<void> delete(String id) async {
    await _service.delete(id);
  }
}
