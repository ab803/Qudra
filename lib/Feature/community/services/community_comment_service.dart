import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/community_comment_model.dart';

class CommunityCommentService {
  final SupabaseClient _client;

  CommunityCommentService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  Future<String> _getCurrentUserId() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found.');
    }
    return user.id;
  }

  Future<List<CommunityCommentModel>> fetchComments(String postId) async {
    final response = await _client
        .from('community_comments')
        .select('id, post_id, author_id, content, created_at')
        .eq('post_id', postId)
        .order('created_at', ascending: true);

    final rows = response.cast<Map<String, dynamic>>();

    if (rows.isEmpty) return [];

    final authorIds = rows
        .map((row) => row['author_id'] as String)
        .toSet()
        .toList();

    final authorNamesMap = await _fetchAuthorNames(authorIds);

    return rows.map((row) {
      final authorId = row['author_id'] as String;
      return CommunityCommentModel.fromMap(
        row,
        authorName: authorNamesMap[authorId] ?? 'Unknown User',
      );
    }).toList();
  }

  Future<CommunityCommentModel> addComment({
    required String postId,
    required String content,
  }) async {
    final trimmedContent = content.trim();

    if (trimmedContent.isEmpty) {
      throw Exception('Comment content cannot be empty.');
    }

    final userId = await _getCurrentUserId();

    final insertedRow = await _client
        .from('community_comments')
        .insert({
      'post_id': postId,
      'author_id': userId,
      'content': trimmedContent,
    })
        .select('id, post_id, author_id, content, created_at')
        .single();

    final authorName = await _fetchAuthorName(userId);

    return CommunityCommentModel.fromMap(
      insertedRow,
      authorName: authorName,
    );
  }

  Future<void> updateComment({
    required String commentId,
    required String content,
  }) async {
    final trimmedContent = content.trim();

    if (trimmedContent.isEmpty) {
      throw Exception('Comment cannot be empty.');
    }

    await _client
        .from('community_comments')
        .update({
      'content': trimmedContent,
      'updated_at': DateTime.now().toIso8601String(),
    })
        .eq('id', commentId);
  }

  Future<void> deleteComment(String commentId) async {
    await _client
        .from('community_comments')
        .delete()
        .eq('id', commentId);
  }

  Future<Map<String, String>> _fetchAuthorNames(List<String> authorIds) async {
    if (authorIds.isEmpty) return {};

    final response = await _client
        .from('people_with_disability')
        .select('id, full_name')
        .inFilter('id', authorIds);

    final Map<String, String> result = {};

    for (final item in response) {
      final map = item as Map<String, dynamic>;
      result[map['id'] as String] =
          map['full_name'] as String? ?? 'Unknown User';
    }

    return result;
  }

  Future<String> _fetchAuthorName(String authorId) async {
    final response = await _client
        .from('people_with_disability')
        .select('full_name')
        .eq('id', authorId)
        .maybeSingle();

    return response?['full_name'] as String? ?? 'Unknown User';
  }
}