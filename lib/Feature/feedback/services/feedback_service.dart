import 'package:supabase_flutter/supabase_flutter.dart';
class FeedbackService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // This getter returns the currently signed-in user id.
  String? get currentUserId => _supabase.auth.currentUser?.id;

  // This helper validates the rating range before insert or update.
  void _validateRating(int rating) {
    if (rating < 1 || rating > 5) {
      throw Exception('Rating must be between 1 and 5.');
    }
  }

  // =========================================================
  // App Feedback
  // =========================================================

  // This method submits app feedback with both rating and comment.
  Future<void> submitAppFeedback({
    required int rating,
    required String comment,
  }) async {
    _validateRating(rating);

    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User is not logged in.');
    }

    final trimmedComment = comment.trim();
    if (trimmedComment.isEmpty) {
      throw Exception('Please enter your feedback comment.');
    }

    await _supabase.from('feedback').insert({
      'people_id': userId,
      'rating': rating,
      'comment': trimmedComment,
    });
  }

  // =========================================================
  // Institution Rating
  // =========================================================

  // This method returns the current user's rating for a specific institution.
  Future<int?> getMyInstitutionRating(String institutionId) async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User is not logged in.');
    }

    final result = await _supabase
        .from('institution_feedback')
        .select('rating')
        .eq('institution_id', institutionId)
        .eq('people_id', userId)
        .maybeSingle();

    if (result == null) {
      return null;
    }

    return (result['rating'] as num).toInt();
  }

  // This method creates or updates the current user's rating for an institution.
  Future<void> submitOrUpdateInstitutionRating({
    required String institutionId,
    required int rating,
  }) async {
    _validateRating(rating);

    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User is not logged in.');
    }

    await _supabase.from('institution_feedback').upsert(
      {
        'institution_id': institutionId,
        'people_id': userId,
        'rating': rating,
        'updated_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'people_id,institution_id',
    );
  }

  // This method returns all rating rows related to a specific institution.
  Future<List<Map<String, dynamic>>> getInstitutionRatings(
      String institutionId,
      ) async {
    final result = await _supabase
        .from('institution_feedback')
        .select('id, institution_id, people_id, rating, created_at, updated_at')
        .eq('institution_id', institutionId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(result);
  }

  // This method calculates the average rating and reviews count for an institution.
  Future<Map<String, dynamic>> getInstitutionRatingSummary(
      String institutionId,
      ) async {
    final ratingsRows = await getInstitutionRatings(institutionId);

    if (ratingsRows.isEmpty) {
      return {
        'average': 0.0,
        'count': 0,
      };
    }

    final ratings = ratingsRows
        .map((row) => (row['rating'] as num).toDouble())
        .toList();

    final total = ratings.fold<double>(0, (sum, value) => sum + value);
    final average = total / ratings.length;

    return {
      'average': double.parse(average.toStringAsFixed(1)),
      'count': ratings.length,
    };
  }
}

// This service handles both app feedback and institution ratings
