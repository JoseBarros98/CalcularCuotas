import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/config/api_config.dart';

class ApiService {
  final String baseUrl = ApiConfig.baseUrl;

  Future<List<T>> fetchList<T>(String endpoint, T Function(Map<String, dynamic>) fromJson) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint/'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> results = data['results']; 
      return results.map((json) => fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load $endpoint: ${response.statusCode} ${response.body}');
    }
  }

  Future<T> fetchOne<T>(String endpoint, int id, T Function(Map<String, dynamic>) fromJson) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint/$id/'));

    if (response.statusCode == 200) {
      return fromJson(json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load $endpoint with id $id: ${response.statusCode} ${response.body}');
    }
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to post to $endpoint: ${response.statusCode} ${response.body}');
    }
  }
  
  
}