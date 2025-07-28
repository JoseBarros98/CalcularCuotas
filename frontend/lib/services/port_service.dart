import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/port.dart';
import 'package:frontend/models/quote_calculation.dart';

class PortService {
  final String _baseUrl = 'http://localhost:8000';

  Future<List<Port>> getPorts() async {
    final response = await http.get(Uri.parse('$_baseUrl/api/v1/ports/'));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      List<dynamic> results = jsonResponse['results'];
      return results.map((port) => Port.fromJson(port)).toList();
    } else {
      throw Exception('Failed to load ports: ${response.statusCode} ${response.body}');
    }
  }

  Future<Port> getPort(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/api/v1/ports/$id/'));

    if (response.statusCode == 200) {
      return Port.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to load port: ${response.statusCode} ${response.body}');
    }
  }

  Future<Port> createPort(Port port) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/ports/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(port.toJson()),
    );

    if (response.statusCode == 201) {
      return Port.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to create port: ${response.statusCode} ${response.body}');
    }
  }

  Future<Port> updatePort(Port port) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/v1/ports/${port.id}/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(port.toJson()),
    );

    if (response.statusCode == 200) {
      return Port.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to update port: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> deletePort(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/api/v1/ports/$id/'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete port: ${response.statusCode} ${response.body}');
    }
  }

  Future<QuoteCalculation> calculateQuote({
    required int originPortId,
    required int destinationPortId,
    required int containerTypeId,
    required int cargoTypeId,
    required int quantity,
    required double weightKg,
    required double volumeCbm,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/calculate-quote/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'origin_port_id': originPortId,
        'destination_port_id': destinationPortId,
        'container_type_id': containerTypeId,
        'cargo_type_id': cargoTypeId,
        'quantity': quantity,
        'weight_kg': weightKg,
        'volume_cbm': volumeCbm,
      }),
    );

    if (response.statusCode == 200) {
      return QuoteCalculation.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      final errorBody = json.decode(utf8.decode(response.bodyBytes));
      throw Exception('Failed to post to quotes/calculate_cuote: ${response.statusCode} ${errorBody}');
    }
  }
}
