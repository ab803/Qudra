class PeopleWithDisabilityModel {
  final String id;
  final DateTime createdAt;
  final String fullName;
  final String phone;
  final String email;
  final String disabilityType;
  final String password;
  final String responsiblePerson;
  final String gender;
  final int age;

  PeopleWithDisabilityModel({
    required this.id,
    required this.createdAt,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.disabilityType,
    required this.password,
    required this.responsiblePerson,
    required this.gender,
    required this.age,
  });

  // ─────────────────────────────────────────
  // FROM JSON (Supabase response → Model)
  // ─────────────────────────────────────────
  factory PeopleWithDisabilityModel.fromJson(Map<String, dynamic> json) {
    return PeopleWithDisabilityModel(
      id:                json['id'] as String,
      createdAt:         DateTime.parse(json['created_at'] as String),
      fullName:          json['full_name'] as String,
      phone:             json['phone'] as String,
      email:             json['email'] as String,
      disabilityType:    json['disability_type'] as String,
      password:          json['password'] as String,
      responsiblePerson: json['responsible_person'] as String,
      gender:            json['gender'] as String,
      age:               json['age'] as int,
    );
  }

  // ─────────────────────────────────────────
  // TO JSON (Model → Supabase insert/update)
  // ─────────────────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      'id':                 id,
      'created_at':         createdAt.toIso8601String(),
      'full_name':          fullName,
      'phone':              phone,
      'email':              email,
      'disability_type':    disabilityType,
      'password':           password,
      'responsible_person': responsiblePerson,
      'gender':             gender,
      'age':                age,
    };
  }

  // ─────────────────────────────────────────
  // COPY WITH (update specific fields)
  // ─────────────────────────────────────────
  PeopleWithDisabilityModel copyWith({
    String? id,
    DateTime? createdAt,
    String? fullName,
    String? phone,
    String? email,
    String? disabilityType,
    String? password,
    String? responsiblePerson,
    String? gender,
    int? age,
  }) {
    return PeopleWithDisabilityModel(
      id:                id                ?? this.id,
      createdAt:         createdAt         ?? this.createdAt,
      fullName:          fullName          ?? this.fullName,
      phone:             phone             ?? this.phone,
      email:             email             ?? this.email,
      disabilityType:    disabilityType    ?? this.disabilityType,
      password:          password          ?? this.password,
      responsiblePerson: responsiblePerson ?? this.responsiblePerson,
      gender:            gender            ?? this.gender,
      age:               age               ?? this.age,
    );
  }

  @override
  String toString() {
    return 'PeopleWithDisabilityModel('
        'id: $id, '
        'fullName: $fullName, '
        'email: $email, '
        'phone: $phone, '
        'disabilityType: $disabilityType, '
        'responsiblePerson: $responsiblePerson, '
        'gender: $gender, '
        'age: $age)';
  }
}