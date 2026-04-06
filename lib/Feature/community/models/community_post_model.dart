class CommunityPostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String content;
  final String disabilityType;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final bool isLikedByCurrentUser;

  CommunityPostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.disabilityType,
    required this.createdAt,
    required this.likesCount,
    required this.commentsCount,
    required this.isLikedByCurrentUser,
  });

  factory CommunityPostModel.fromMap(
      Map<String, dynamic> map, {
        required String authorName,
        required int likesCount,
        required int commentsCount,
        required bool isLikedByCurrentUser,
      }) {
    return CommunityPostModel(
      id: map['id'] as String,
      authorId: map['author_id'] as String,
      authorName: authorName,
      content: map['content'] as String? ?? '',
      disabilityType: map['disability_type'] as String? ?? 'Other',
      createdAt: DateTime.parse(map['created_at'] as String),
      likesCount: likesCount,
      commentsCount: commentsCount,
      isLikedByCurrentUser: isLikedByCurrentUser,
    );
  }

  CommunityPostModel copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? content,
    String? disabilityType,
    DateTime? createdAt,
    int? likesCount,
    int? commentsCount,
    bool? isLikedByCurrentUser,
  }) {
    return CommunityPostModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      content: content ?? this.content,
      disabilityType: disabilityType ?? this.disabilityType,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLikedByCurrentUser:
      isLikedByCurrentUser ?? this.isLikedByCurrentUser,
    );
  }
}