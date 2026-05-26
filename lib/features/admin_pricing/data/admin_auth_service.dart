import '../../../core/api/api_client.dart';
import '../../../core/storage/local_storage.dart';

class AdminSession {
  final String token;
  final String username;
  final String role;
  final String expiresAt;

  const AdminSession({
    required this.token,
    required this.username,
    required this.role,
    required this.expiresAt,
  });

  factory AdminSession.fromJson(Map<String, dynamic> json) {
    return AdminSession(
      token: json['token']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      expiresAt: json['expiresAt']?.toString() ?? '',
    );
  }
}

class AdminAuthService {
  static const String tokenKey = 'pera_x_admin_token';
  static const String usernameKey = 'pera_x_admin_username';

  final ApiClient _apiClient;

  AdminAuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  static String? get token => LocalStorage.getString(tokenKey);

  static bool get isLoggedIn {
    final value = token;
    return value != null && value.isNotEmpty;
  }

  Future<AdminSession> login({
    required String username,
    required String accessCode,
  }) async {
    final response = await _apiClient.post(
      '/admin/api/auth/login',
      body: {
        'username': username,
        'accessCode': accessCode,
      },
    );

    final session = AdminSession.fromJson(response as Map<String, dynamic>);
    if (session.token.isEmpty) {
      throw Exception('Admin login failed. No token returned.');
    }

    await LocalStorage.setString(tokenKey, session.token);
    await LocalStorage.setString(usernameKey, session.username);
    return session;
  }

  static Future<void> logout() async {
    await LocalStorage.remove(tokenKey);
    await LocalStorage.remove(usernameKey);
  }
}
