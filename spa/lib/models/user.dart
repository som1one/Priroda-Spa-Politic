class User {
  final int id;
  final String name;
  final String? surname;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final bool isVerified;
  final int? loyaltyLevel;

  User({
    required this.id,
    required this.name,
    this.surname,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.isVerified = false,
    this.loyaltyLevel,
  });

  String get fullName {
    if (surname != null && surname!.isNotEmpty) {
      return '$name $surname';
    }
    return name;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] as String? ?? '',
      surname: json['surname'] as String?,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      loyaltyLevel: json['loyalty_level'] is int
          ? json['loyalty_level'] as int?
          : json['loyalty_level'] != null
              ? int.tryParse(json['loyalty_level'].toString())
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
      'is_verified': isVerified,
      'loyalty_level': loyaltyLevel,
    };
  }

  User copyWith({
    int? id,
    String? name,
    String? surname,
    String? email,
    String? phone,
    String? avatarUrl,
    bool? isVerified,
    int? loyaltyLevel,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
      loyaltyLevel: loyaltyLevel ?? this.loyaltyLevel,
    );
  }
}

