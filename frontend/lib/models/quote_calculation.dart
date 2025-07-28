import 'package:frontend/models/port.dart';
import 'package:frontend/models/container.dart';

class QuoteCalculation {
  final Port originPort;
  final Port destinationPort;
  final ContainerType containerType;
  final CargoType cargoType;
  final int quantity;
  final double weightKg;
  final double volumeCbm;
  final double estimatedTransitDays;
  final Map<String, dynamic> breakdown;
  final double totalItemCost;
  final double totalQuoteAmount;
  final DateTime validUntil;

  QuoteCalculation({
    required this.originPort,
    required this.destinationPort,
    required this.containerType,
    required this.cargoType,
    required this.quantity,
    required this.weightKg,
    required this.volumeCbm,
    required this.estimatedTransitDays,
    required this.breakdown,
    required this.totalItemCost,
    required this.totalQuoteAmount,
    required this.validUntil,
  });

  factory QuoteCalculation.fromJson(Map<String, dynamic> json) {
    return QuoteCalculation(
      originPort: Port.fromJson(json['origin_port']),
      destinationPort: Port.fromJson(json['destination_port']),
      containerType: ContainerType.fromJson(json['container_type']),
      cargoType: CargoType.fromJson(json['cargo_type']),
      quantity: json['quantity'] as int,
      weightKg: (json['weight_kg'] as num).toDouble(),
      volumeCbm: (json['volume_cbm'] as num).toDouble(),
      estimatedTransitDays: (json['estimated_transit_days'] as num).toDouble(),
      breakdown: Map<String, dynamic>.from(json['breakdown']),
      totalItemCost: (json['total_item_cost'] as num).toDouble(),
      totalQuoteAmount: (json['total_quote_amount'] as num).toDouble(),
      validUntil: DateTime.parse(json['valid_until']),
    );
  }
}
