import 'package:frontend/models/port.dart';

class ShippingRoute {
  final int id;
  final Port originPort;
  final Port destinationPort;
  final double distanceNauticalMiles;
  final int estimatedTransitDays;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ShippingRoute({
    required this.id,
    required this.originPort,
    required this.destinationPort,
    required this.distanceNauticalMiles,
    required this.estimatedTransitDays,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShippingRoute.fromJson(Map<String, dynamic> json) {
    return ShippingRoute(
      id: json['id'] as int,
      originPort: Port.fromJson(json['origin_port'] as Map<String, dynamic>),
      destinationPort: Port.fromJson(json['destination_port'] as Map<String, dynamic>),
      distanceNauticalMiles: json['distance_nautical_miles'] == null
          ? 0.0
          : (json['distance_nautical_miles'] is String
              ? double.tryParse(json['distance_nautical_miles'] as String) ?? 0.0
              : (json['distance_nautical_miles'] as num).toDouble()),
      estimatedTransitDays: json['estimated_transit_days'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'origin_port_id': originPort.id,
      'destination_port_id': destinationPort.id,
      'distance_nautical_miles': distanceNauticalMiles,
      'estimated_transit_days': estimatedTransitDays,
      'is_active': isActive,
    };
  }

  @override
  String toString() {
    return '${originPort.code} -> ${destinationPort.code}';
  }
}
