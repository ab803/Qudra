import 'package:supabase_flutter/supabase_flutter.dart';
import '../../Models/people_with_disabilityModel.dart';
import 'AuthService.dart';

class PeopleWithDisabilityService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AuthService _authService; // ✅ Inject as instance
  final String _table = 'people_with_disability';

  // ✅ Accept AuthService via constructor
  PeopleWithDisabilityService({AuthService? authService})
      : _authService = authService ?? AuthService();

  // ─────────────────────────────────────────
  // REGISTER
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
  }) async {
    try {
      // Step 1: Create auth user
      final authResponse = await _authService.signUp( // ✅ instance call
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Registration failed: No user returned');
      }

      // Step 2: Save profile to table
      final person = PeopleWithDisabilityModel(
        id:                authResponse.user!.id,
        createdAt:         DateTime.now(),
        fullName:          fullName,
        phone:             phone,
        email:             email,
        disabilityType:    disabilityType,
        password:          password,
        responsiblePerson: responsiblePerson,
        gender:            gender,
        age:               age,
      );

      await _supabase.from(_table).upsert(person.toJson());

      return person;
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  // ─────────────────────────────────────────
  // GET CURRENT PROFILE
  // ─────────────────────────────────────────
  Future<PeopleWithDisabilityModel?> getCurrentProfile() async {
    try {
      final userId = _authService.currentUser?.id; // ✅ instance call
      if (userId == null) return null;

      final data = await _supabase
          .from(_table)
          .select()
          .eq('id', userId)
          .single();

      return PeopleWithDisabilityModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  // ─────────────────────────────────────────
  // GET ALL
  // ─────────────────────────────────────────
  Future<List<PeopleWithDisabilityModel>> getAll() async {
    try {
      final data = await _supabase.from(_table).select();

      return (data as List)
          .map((e) => PeopleWithDisabilityModel.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch records: $e');
    }
  }

  // ─────────────────────────────────────────
  // GET BY ID
  // ─────────────────────────────────────────
  Future<PeopleWithDisabilityModel> getById(String id) async {
    try {
      final data = await _supabase
          .from(_table)
          .select()
          .eq('id', id)
          .single();

      return PeopleWithDisabilityModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get record: $e');
    }
  }

  // ─────────────────────────────────────────
  // UPDATE PROFILE
  // ─────────────────────────────────────────
  Future<void> updateProfile({
    required String id,
    String? fullName,
    String? phone,
    String? disabilityType,
    String? responsiblePerson,
    String? gender,
    int? age,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (fullName != null)          updates['full_name']          = fullName;
      if (phone != null)             updates['phone']              = phone;
      if (disabilityType != null)    updates['disability_type']    = disabilityType;
      if (responsiblePerson != null) updates['responsible_person'] = responsiblePerson;
      if (gender != null)            updates['gender']             = gender;
      if (age != null)               updates['age']                = age;

      await _supabase.from(_table).update(updates).eq('id', id);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // ─────────────────────────────────────────
  // DELETE
  // ─────────────────────────────────────────
  Future<void> delete(String id) async {
    try {
      await _supabase.from(_table).delete().eq('id', id);
      await _authService.logout(); // ✅ instance call
    } catch (e) {
      throw Exception('Failed to delete record: $e');
    }
  }
}