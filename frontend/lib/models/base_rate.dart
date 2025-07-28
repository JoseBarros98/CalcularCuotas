import 'package:frontend/models/shipping_route.dart';
import 'package:frontend/models/container.dart';

class BaseRate {
  final int id;
  final ShippingRoute route;
  final ContainerType containerType;
  final double baseRateUsd;
  final double fuelSurchargePercentage;
  final double handlingFeeUsd;
  final double insuranceFeePercentage;
  final double documentationFeeUsd;
  final DateTime effectiveFrom;
  final DateTime? effectiveTo;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  BaseRate({
    required this.id,
    required this.route,
    required this.containerType,
    required this.baseRateUsd,
    required this.fuelSurchargePercentage,
    required this.handlingFeeUsd,
    required this.insuranceFeePercentage,
    required this.documentationFeeUsd,
    required this.effectiveFrom,
    this.effectiveTo,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BaseRate.fromJson(Map<String, dynamic> json) {
    return BaseRate(
      id: json['id'] as int,
      route: ShippingRoute.fromJson(json['route'] as Map<String, dynamic>),
      containerType: ContainerType.fromJson(json['container_type'] as Map<String, dynamic>),
      baseRateUsd: json['base_rate_usd'] == null
          ? 0.0
          : (json['base_rate_usd'] is String
              ? double.tryParse(json['base_rate_usd'] as String) ?? 0.0
              : (json['base_rate_usd'] as num).toDouble()),
      fuelSurchargePercentage: json['fuel_surcharge_percentage'] == null
          ? 0.0
          : (json['fuel_surcharge_percentage'] is String
              ? double.tryParse(json['fuel_surcharge_percentage'] as String) ?? 0.0
              : (json['fuel_surcharge_percentage'] as num).toDouble()),
      handlingFeeUsd: json['handling_fee_usd'] == null
          ? 0.0
          : (json['handling_fee_usd'] is String
              ? double.tryParse(json['handling_fee_usd'] as String) ?? 0.0
              : (json['handling_fee_usd'] as num).toDouble()),
      insuranceFeePercentage: json['insurance_fee_percentage'] == null
          ? 0.0
          : (json['insurance_fee_percentage'] is String
              ? double.tryParse(json['insurance_fee_percentage'] as String) ?? 0.0
              : (json['insurance_fee_percentage'] as num).toDouble()),
      documentationFeeUsd: json['documentation_fee_usd'] == null
          ? 0.0
          : (json['documentation_fee_usd'] is String
              ? double.tryParse(json['documentation_fee_usd'] as String) ?? 0.0
              : (json['documentation_fee_usd'] as num).toDouble()),
      effectiveFrom: DateTime.parse(json['effective_from'] as String? ?? DateTime.now().toIso8601String()),
      effectiveTo: json['effective_to'] == null
          ? null
          : DateTime.parse(json['effective_to'] as String),
      isActive: json['is_active'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'route_id': route.id,
      'container_type_id': containerType.id,
      'base_rate_usd': baseRateUsd,
      'fuel_surcharge_percentage': fuelSurchargePercentage,
      'handling_fee_usd': handlingFeeUsd,
      'insurance_fee_percentage': insuranceFeePercentage,
      'documentation_fee_usd': documentationFeeUsd,
      'effective_from': effectiveFrom.toIso8601String(),
      'effective_to': effectiveTo?.toIso8601String(),
      'is_active': isActive,
    };
  }

  @override
  String toString() {
    return 'Rate for ${route.originPort.code}-${route.destinationPort.code} (${containerType.name})';
  }
}
