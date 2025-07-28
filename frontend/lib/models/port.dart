import 'package:frontend/models/country.dart';
class Port {
  final int id;
  final String name;
  final String code;
  final Country country;
  final String city;
  final double? latitude;
  final double? longitude;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Port({
    required this.id,
    required this.name,
    required this.code,
    required this.country,
    required this.city,
    this.latitude,
    this.longitude,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Port.fromJson(Map<String, dynamic> json) {
    return Port(
      id: json['id'] as int, 
      name: json['name'] as String, 
      code: json['code'] as String, 
      country: Country.fromJson(json['country'] as Map<String, dynamic>), 
      city: json['city'] as String, 
      latitude: json['latitude'] == null
          ? null
          : (json['latitude'] is String
              ? double.tryParse(json['latitude'] as String) 
              : (json['latitude'] as num).toDouble()), 
      longitude: json['longitude'] == null
          ? null
          : (json['longitude'] is String
              ? double.tryParse(json['longitude'] as String) 
              : (json['longitude'] as num).toDouble()), 
      isActive: json['is_active'] as bool, 
      createdAt: DateTime.parse(json['created_at'] as String), 
      updatedAt: DateTime.parse(json['updated_at'] as String), 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'country': country.toJson(),
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return '$name ($code)';
  }
}

