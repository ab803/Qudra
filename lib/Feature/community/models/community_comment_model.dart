class CommunityCommentModel {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String content;
  final DateTime createdAt;

  CommunityCommentModel({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.createdAt,
  });

  factory CommunityCommentModel.fromMap(
      Map<String, dynamic> map, {
        required String authorName,
      }) {
    return CommunityCommentModel(
      id: map['id'] as String,
      postId: map['post_id'] as String,
      authorId: map['author_id'] as String,
      authorName: authorName,
      content: map['content'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  CommunityCommentModel copyWith({
    String? id,
    String? postId,
    String? authorId,
    String? authorName,
    String? content,
    DateTime? createdAt,
  }) {
    return CommunityCommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}