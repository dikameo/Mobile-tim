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

  // ================= FROM JSON (LOCAL STORAGE) =================
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      photoUrl: json['photoUrl'],
    );
  }

  // ================= TO JSON (LOCAL STORAGE) =================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
    };
  }

  // ================= COPY WITH (🔥 AUTO REFRESH SUPPORT) =================
  User copyWith({
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  // ================= FROM SUPABASE PROFILE =================
  factory User.fromSupabase({
    required String id,
    required String email,
    required String phone,
    required Map<String, dynamic> profile,
  }) {
    return User(
      id: id,
      name: profile['username'] ?? '',
      email: email,
      phone: phone,
      photoUrl: profile['avatar_url'],
    );
  }
}
