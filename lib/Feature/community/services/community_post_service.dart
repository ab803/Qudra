import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/community_post_model.dart';

class CommunityPostService {
  final SupabaseClient _client;

  CommunityPostService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  Future<String> _getCurrentUserId() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found.');
    }
    return user.id;
  }

  Future<String> fetchCurrentUserId() async {
    return _getCurrentUserId();
  }

  Future<String?> getCurrentUserDisabilityType() async {
    final userId = await _getCurrentUserId();

    final response = await _client
        .from('people_with_disability')
        .select('disability_type')
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;

    return response['disability_type'] as String?;
  }

  Future<void> createPost({
    required String content,
  }) async {
    final trimmedContent = content.trim();

    if (trimmedContent.isEmpty) {
      throw Exception('Post content cannot be empty.');
    }

    final userId = await _getCurrentUserId();
    final disabilityType = await getCurrentUserDisabilityType();

    if (disabilityType == null || disabilityType.isEmpty) {
      throw Exception('User disability type not found.');
    }

    await _client.from('community_posts').insert({
      'author_id': userId,
      'content': trimmedContent,
      'disability_type': disabilityType,
    });
  }

  Future<void> updatePost({
    required String postId,
    required String content,
  }) async {
    final trimmedContent = content.trim();

    if (trimmedContent.isEmpty) {
      throw Exception('Post content cannot be empty.');
    }

    await _client
        .from('community_posts')
        .update({
      'content': trimmedContent,
      'updated_at': DateTime.now().toIso8601String(),
    })
        .eq('id', postId);
  }

  Future<void> deletePost(String postId) async {
    await _client
        .from('community_posts')
        .delete()
        .eq('id', postId);
  }

  Future<void> likePost(String postId) async {
    final userId = await _getCurrentUserId();

    await _client.from('community_likes').insert({
      'post_id': postId,
      'user_id': userId,
    });
  }

  Future<void> unlikePost(String postId) async {
    final userId = await _getCurrentUserId();

    await _client
        .from('community_likes')
        .delete()
        .eq('post_id', postId)
        .eq('user_id', userId);
  }

  Future<List<CommunityPostModel>> fetchAllPosts() async {
    final disabilityType = await getCurrentUserDisabilityType();

    if (disabilityType == null || disabilityType.isEmpty) {
      return [];
    }

    final response = await _client
        .from('community_posts')
        .select('id, author_id, content, disability_type, created_at')
        .eq('disability_type', disabilityType)
        .order('created_at', ascending: false);

    return _buildPosts(response);
  }

  Future<List<CommunityPostModel>> fetchMyPosts() async {
    final userId = await _getCurrentUserId();

    final response = await _client
        .from('community_posts')
        .select('id, author_id, content, disability_type, created_at')
        .eq('author_id', userId)
        .order('created_at', ascending: false);

    return _buildPosts(response);
  }

  Future<List<CommunityPostModel>> _buildPosts(List<dynamic> rows) async {
    if (rows.isEmpty) return [];

    final castedRows = rows.cast<Map<String, dynamic>>();

    final authorIds = castedRows
        .map((row) => row['author_id'] as String)
        .toSet()
        .toList();

    final postIds = castedRows
        .map((row) => row['id'] as String)
        .toList();

    final authorNamesMap = await _fetchAuthorNames(authorIds);
    final likedPostIds = await _fetchLikedPostIds(postIds);

    final List<CommunityPostModel> posts = [];

    for (final row in castedRows) {
      final postId = row['id'] as String;
      final authorId = row['author_id'] as String;

      final likesCount = await _countRowsByPostId(
        tableName: 'community_likes',
        postId: postId,
      );

      final commentsCount = await _countRowsByPostId(
        tableName: 'community_comments',
        postId: postId,
      );

      posts.add(
        CommunityPostModel.fromMap(
          row,
          authorName: authorNamesMap[authorId] ?? 'Unknown User',
          likesCount: likesCount,
          commentsCount: commentsCount,
          isLikedByCurrentUser: likedPostIds.contains(postId),
        ),
      );
    }

    return posts;
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

  Future<Set<String>> _fetchLikedPostIds(List<String> postIds) async {
    if (postIds.isEmpty) return {};

    final userId = await _getCurrentUserId();

    final response = await _client
        .from('community_likes')
        .select('post_id')
        .eq('user_id', userId)
        .inFilter('post_id', postIds);

    return response
        .map<String>(
          (item) => (item as Map<String, dynamic>)['post_id'] as String,
    )
        .toSet();
  }

  Future<int> _countRowsByPostId({
    required String tableName,
    required String postId,
  }) async {
    final response = await _client
        .from(tableName)
        .select('id')
        .eq('post_id', postId);

    return response.length;
  }
}