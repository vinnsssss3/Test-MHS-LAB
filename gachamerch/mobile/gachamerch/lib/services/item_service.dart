import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import '../models/item.dart';
import '../models/store.dart';
import 'storage_service.dart';

class ItemService {
  static Future<Map<String, String>> _authHeaders() async {
    final token = await StorageService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<List<StoreInfo>> fetchStores() async {
    final res = await http.get(Uri.parse('${ApiConfig.baseUrl}/items/stores'));
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return (data['stores'] as List)
        .map((s) => StoreInfo.fromJson(s as Map<String, dynamic>))
        .toList();
  }

  static Future<List<Item>> fetchItems({String? store, String? type, String? q}) async {
    final query = <String, String>{};
    if (store != null) query['store'] = store;
    if (type  != null) query['type']  = type;
    if (q     != null) query['q']     = q;
    final uri = Uri.parse('${ApiConfig.baseUrl}/items').replace(queryParameters: query);
    final res = await http.get(uri);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return (data['items'] as List).map((i) => Item.fromJson(i as Map<String, dynamic>)).toList();
  }

  static Future<Item> fetchItem(int id) async {
    final res = await http.get(Uri.parse('${ApiConfig.baseUrl}/items/$id'));
    if (res.statusCode != 200) throw Exception('Item not found');
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return Item.fromJson(data['item'] as Map<String, dynamic>);
  }

  static Future<Item> createItem(Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/items'),
      headers: await _authHeaders(),
      body: jsonEncode(body),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 400) throw Exception(data['error'] ?? 'Create failed');
    return Item.fromJson(data['item'] as Map<String, dynamic>);
  }

  static Future<Item> updateItem(int id, Map<String, dynamic> body) async {
    final res = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/items/$id'),
      headers: await _authHeaders(),
      body: jsonEncode(body),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 400) throw Exception(data['error'] ?? 'Update failed');
    return Item.fromJson(data['item'] as Map<String, dynamic>);
  }

  static Future<void> deleteItem(int id) async {
    final res = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/items/$id'),
      headers: await _authHeaders(),
    );
    if (res.statusCode >= 400) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      throw Exception(data['error'] ?? 'Delete failed');
    }
  }

  static Future<Map<String, dynamic>> buyItem(int id, int quantity) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/items/$id/buy'),
      headers: await _authHeaders(),
      body: jsonEncode({'quantity': quantity}),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 400) throw Exception(data['error'] ?? 'Purchase failed');
    return data;
  }
}
