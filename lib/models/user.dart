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

  // Dummy user
  static User getDummyUser() {
    return User(
      id: '1',
      name: 'John Doe',
      email: 'john.doe@roastmaster.id',
      phone: '+62 812-3456-7890',
      photoUrl: 'https://i.pravatar.cc/150?img=12',
    );
  }
}
