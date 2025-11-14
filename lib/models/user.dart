class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? photoUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.photoUrl,
  });

  // Convert from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      photoUrl: json['photoUrl'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
    };
  }
}
