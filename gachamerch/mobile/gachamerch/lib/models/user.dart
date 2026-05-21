class User {
  final int id;
  final String username;
  final String email;
  final String role;
  final String oauthProvider;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.oauthProvider,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';

  factory User.fromJson(Map<String, dynamic> j) => User(
    id:            j['id'] as int,
    username:      j['username'] as String,
    email:         j['email'] as String,
    role:          j['role'] as String,
    oauthProvider: j['oauth_provider'] as String? ?? 'local',
    createdAt:     DateTime.parse(j['created_at'] as String),
  );
}
