class InstitutionModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String? description;
  final String institutionType;
  final String location;
  final DateTime? createdAt;

  InstitutionModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.description,
    required this.institutionType,
    required this.location,
    this.createdAt,
  });

  // Create institution model from Supabase row
  factory InstitutionModel.fromJson(Map<String, dynamic> json) {
    return InstitutionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      description: json['description'] as String?,
      institutionType: json['institution_type'] as String,
      location: json['location'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}