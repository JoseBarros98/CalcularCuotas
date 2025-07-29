import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/base_rate.dart';

class BaseRateService {
  final String _baseUrl = 'http://192.168.1.20:8000';

  Future<List<BaseRate>> getBaseRates() async {
    final response = await http.get(Uri.parse('$_baseUrl/api/v1/base-rates/'));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      List<dynamic> results = jsonResponse['results'];
      return results.map((br) => BaseRate.fromJson(br)).toList();
    } else {
      throw Exception('Failed to load base rates: ${response.statusCode} ${response.body}');
    }
  }

  Future<BaseRate> getBaseRate(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/api/v1/base-rates/$id/'));

    if (response.statusCode == 200) {
      return BaseRate.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to load base rate: ${response.statusCode} ${response.body}');
    }
  }

  Future<BaseRate> createBaseRate(BaseRate baseRate) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/base-rates/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(baseRate.toJson()),
    );

    if (response.statusCode == 201) {
      return BaseRate.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to create base rate: ${response.statusCode} ${response.body}');
    }
  }

  Future<BaseRate> updateBaseRate(BaseRate baseRate) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/v1/base-rates/${baseRate.id}/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(baseRate.toJson()),
    );

    if (response.statusCode == 200) {
      return BaseRate.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to update base rate: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> deleteBaseRate(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/api/v1/base-rates/$id/'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete base rate: ${response.statusCode} ${response.body}');
    }
  }
}
