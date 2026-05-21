import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import '../models/purchase.dart';
import 'storage_service.dart';

class PurchaseService {
  static Future<Map<String, String>> _authHeaders() async {
    final token = await StorageService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<List<Purchase>> fetchMyPurchases() async {
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/purchases/me'),
      headers: await _authHeaders(),
    );
    if (res.statusCode >= 400) throw Exception('Could not load purchase history');
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return (data['purchases'] as List)
        .map((p) => Purchase.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  static Future<List<Purchase>> fetchAllPurchases() async {
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/purchases'),
      headers: await _authHeaders(),
    );
    if (res.statusCode >= 400) throw Exception('Could not load purchases');
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return (data['purchases'] as List)
        .map((p) => Purchase.fromJson(p as Map<String, dynamic>))
        .toList();
  }
}
