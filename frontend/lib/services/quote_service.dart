import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/quote_calculation.dart';

class QuoteService {
  final String _baseUrl = 'http://192.168.1.20:8000';

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
      Uri.parse('$_baseUrl/api/v1/calculate_quote/'),
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
      throw Exception('Failed to post to quotes/calculate_cuote: ${response.statusCode} $errorBody');
    }
  }
}
