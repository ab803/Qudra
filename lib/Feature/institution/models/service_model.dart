class InstitutionServiceModel {
  final String id;
  final String institutionId;
  final String name;
  final String category;
  final String? description;
  final List<String> supportedDisabilities;
  final double price;
  final bool isFree;
  final int durationMinutes;
  final String locationMode;
  final String bookingType;
  final String? availabilityNotes;
  final bool isActive;
  final DateTime? createdAt;

  InstitutionServiceModel({
    required this.id,
    required this.institutionId,
    required this.name,
    required this.category,
    this.description,
    required this.supportedDisabilities,
    required this.price,
    required this.isFree,
    required this.durationMinutes,
    required this.locationMode,
    required this.bookingType,
    this.availabilityNotes,
    required this.isActive,
    this.createdAt,
  });

  // Create service model from Supabase row
  factory InstitutionServiceModel.fromJson(Map<String, dynamic> json) {
    return InstitutionServiceModel(
      id: json['id'] as String,
      institutionId: json['institution_id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
      supportedDisabilities:
      (json['supported_disabilities'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      price: (json['price'] as num).toDouble(),
      isFree: (json['is_free'] as bool?) ?? false,
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 30,
      locationMode: (json['location_mode'] as String?) ?? 'on_site',
      bookingType: (json['booking_type'] as String?) ?? 'request',
      availabilityNotes: json['availability_notes'] as String?,
      isActive: (json['is_active'] as bool?) ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}
