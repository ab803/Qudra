// This enum defines the supported awareness content types stored in Supabase.
enum AwarenessContentType {
  tip,
  right,
  article,
  video,
}

// This extension converts awareness content types to and from stable database values.
extension AwarenessContentTypeX on AwarenessContentType {
  String get value {
    switch (this) {
      case AwarenessContentType.tip:
        return 'tip';
      case AwarenessContentType.right:
        return 'right';
      case AwarenessContentType.article:
        return 'article';
      case AwarenessContentType.video:
        return 'video';
    }
  }

  // This helper safely converts Supabase text values into enum values.
  static AwarenessContentType fromValue(String? value) {
    switch ((value ?? '').trim().toLowerCase()) {
      case 'right':
        return AwarenessContentType.right;
      case 'article':
        return AwarenessContentType.article;
      case 'video':
        return AwarenessContentType.video;
      case 'tip':
      default:
        return AwarenessContentType.tip;
    }
  }
}

class tipsRightsModel {
  final int id;
  final DateTime createdAt;
  final String title;
  final String description;
  final List<String> disabilityType;

  // This field stores whether the content is a tip, right, article, or video.
  final AwarenessContentType contentType;

  // This optional field stores an external video/article URL when needed.
  final String? mediaUrl;

  // This optional field stores estimated article reading time in minutes.
  final int? readTimeMinutes;

  // This flag marks whether this item can appear as a Daily Tip.
  final bool isDailyTip;

  // This flag marks whether this item is highlighted as featured content.
  final bool isFeatured;

  const tipsRightsModel({
    required this.id,
    required this.createdAt,
    required this.title,
    required this.description,
    required this.disabilityType,
    this.contentType = AwarenessContentType.tip,
    this.mediaUrl,
    this.readTimeMinutes,
    this.isDailyTip = false,
    this.isFeatured = false,
  });

  // This helper safely reads the disability_type JSONB value from Supabase.
  static List<String> _parseDisabilityTypes(dynamic value) {
    if (value == null) return <String>[];

    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }

    if (value is String) {
      return value
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    return <String>[];
  }

  // This helper safely reads bool values from Supabase or local fallback values.
  static bool _parseBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;

    if (value is bool) return value;

    if (value is num) return value == 1;

    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1' || normalized == 'yes';
    }

    return defaultValue;
  }

  // This helper safely reads integer values from Supabase.
  static int? _parseInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    if (value is num) return value.toInt();

    if (value is String) return int.tryParse(value.trim());

    return null;
  }

  // This factory creates the model from a Supabase row while keeping old rows backward-compatible.
  factory tipsRightsModel.fromJson(Map<String, dynamic> json) {
    return tipsRightsModel(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      title: (json['title'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      disabilityType: _parseDisabilityTypes(json['disability_type']),

      // This block defaults old database rows to tip if content_type does not exist yet.
      contentType: AwarenessContentTypeX.fromValue(
        json['content_type'] as String?,
      ),

      // This block reads the optional media URL used mainly for video content.
      mediaUrl: json['media_url'] as String?,

      // This block reads the optional article reading time.
      readTimeMinutes: _parseInt(json['read_time_minutes']),

      // This block reads the daily tip flag and defaults to false.
      isDailyTip: _parseBool(json['is_daily_tip']),

      // This block reads the featured flag and defaults to false.
      isFeatured: _parseBool(json['is_featured']),
    );
  }

  // This method converts the model to a Supabase insert/update payload.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'disability_type': disabilityType,

      // This block stores the selected awareness content type in Supabase.
      'content_type': contentType.value,

      // This block stores a video/article URL only when provided.
      'media_url': mediaUrl,

      // This block stores article reading time only when provided.
      'read_time_minutes': readTimeMinutes,

      // This block stores whether the item can be used as a Daily Tip.
      'is_daily_tip': isDailyTip,

      // This block stores whether the item is highlighted as featured content.
      'is_featured': isFeatured,
    };
  }

  tipsRightsModel copyWith({
    int? id,
    DateTime? createdAt,
    String? title,
    String? description,
    List<String>? disabilityType,
    AwarenessContentType? contentType,
    String? mediaUrl,
    int? readTimeMinutes,
    bool? isDailyTip,
    bool? isFeatured,
  }) {
    return tipsRightsModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      title: title ?? this.title,
      description: description ?? this.description,
      disabilityType: disabilityType ?? this.disabilityType,

      // This block preserves or updates the awareness content type.
      contentType: contentType ?? this.contentType,

      // This block preserves or updates the optional media URL.
      mediaUrl: mediaUrl ?? this.mediaUrl,

      // This block preserves or updates the optional read time.
      readTimeMinutes: readTimeMinutes ?? this.readTimeMinutes,

      // This block preserves or updates the Daily Tip flag.
      isDailyTip: isDailyTip ?? this.isDailyTip,

      // This block preserves or updates the Featured flag.
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }
}