import 'package:frontend/models/quote_calculation.dart';
import 'package:frontend/services/api_service.dart';

class QuoteService {
  final ApiService _apiService = ApiService();

  Future<QuoteCalculation> calculateQuote({
    required int originPortId,
    required int destinationPortId,
    required int containerTypeId,
    required int cargoTypeId,
    required int quantity,
    required double weightKg,
    required double volumeCbm,
  }) async {
    final data = {
      'origin_port_id': originPortId,
      'destination_port_id': destinationPortId,
      'container_type_id': containerTypeId,
      'cargo_type_id': cargoTypeId,
      'quantity': quantity,
      'weight_kg': weightKg,
      'volume_cbm': volumeCbm,
    };
    final response = await _apiService.post('quotes/calculate_quote', data);
    return QuoteCalculation.fromJson(response);
  }
}