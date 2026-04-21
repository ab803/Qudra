class tipsRightsModel {
  final int id;
  final DateTime createdAt;
  final String title;
  final String description;
  final List<String> disabilityType;

  const tipsRightsModel({
    required this.id,
    required this.createdAt,
    required this.title,
    required this.description,
    required this.disabilityType,
  });

  factory tipsRightsModel.fromJson(Map<String, dynamic> json) => tipsRightsModel(
    id: json['id'] as int,
    createdAt: DateTime.parse(json['created_at'] as String),
    title: json['title'] as String,
    description: json['description'] as String,
    disabilityType: List<String>.from(json['disability_type'] as List),
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'disability_type': disabilityType,
  };

  tipsRightsModel copyWith({
    int? id,
    DateTime? createdAt,
    String? title,
    String? description,
    List<String>? disabilityType,
  }) =>
      tipsRightsModel(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        title: title ?? this.title,
        description: description ?? this.description,
        disabilityType: disabilityType ?? this.disabilityType,
      );
}