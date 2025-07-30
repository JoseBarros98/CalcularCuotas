import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/country.dart';

class CountryService {
  final String _baseUrl = 'http://localhost:8000';

  Future<List<Country>> getCountries() async {
    final response = await http.get(Uri.parse('$_baseUrl/api/v1/countries/'));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      List<dynamic> results = jsonResponse['results'];
      return results.map((country) => Country.fromJson(country)).toList();
    } else {
      throw Exception('Failed to load countries: ${response.statusCode} ${response.body}');
    }
  }

  Future<Country> getCountry(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/api/v1/countries/$id/'));

    if (response.statusCode == 200) {
      return Country.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to load country: ${response.statusCode} ${response.body}');
    }
  }

  Future<Country> createCountry(Country country) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/countries/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(country.toJson()),
    );

    if (response.statusCode == 201) {
      return Country.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to create country: ${response.statusCode} ${response.body}');
    }
  }

  Future<Country> updateCountry(Country country) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/v1/countries/${country.id}/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(country.toJson()),
    );

    if (response.statusCode == 200) {
      return Country.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to update country: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> deleteCountry(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/api/v1/countries/$id/'));

    if (response.statusCode != 204) { // 204 No Content
      throw Exception('Failed to delete country: ${response.statusCode} ${response.body}');
    }
  }
}
