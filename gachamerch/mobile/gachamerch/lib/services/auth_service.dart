import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import '../models/user.dart';
import 'storage_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body,
      {String? token}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: headers,
      body: jsonEncode(body),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 400) throw Exception(data['error'] ?? 'Request failed');
    return data;
  }

  static Future<User> register(String username, String email, String password) async {
    final data = await _post('/auth/register', {
      'username': username, 'email': email, 'password': password,
    });
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  static Future<({User user, String token})> login(String username, String password) async {
    final data = await _post('/auth/login', {'username': username, 'password': password});
    final user  = User.fromJson(data['user'] as Map<String, dynamic>);
    final token = data['token'] as String;
    await StorageService.saveToken(token);
    return (user: user, token: token);
  }

  static Future<({User user, String token})> googleLogin(String idToken) async {
    final data = await _post('/auth/google', {'idToken': idToken});
    final user  = User.fromJson(data['user'] as Map<String, dynamic>);
    final token = data['token'] as String;
    await StorageService.saveToken(token);
    return (user: user, token: token);
  }

  static Future<User?> fetchMe() async {
    final token = await StorageService.getToken();
    if (token == null) return null;
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/auth/me'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) return null;
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }
}
