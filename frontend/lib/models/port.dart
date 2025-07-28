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
      id: json['id'] as int, // Conversión explícita
      name: json['name'] as String, // Conversión explícita
      code: json['code'] as String, // Conversión explícita
      country: Country.fromJson(json['country'] as Map<String, dynamic>), // Conversión explícita
      city: json['city'] as String, // Conversión explícita
      latitude: json['latitude'] == null
          ? null
          : (json['latitude'] is String
              ? double.tryParse(json['latitude'] as String) // Si es String, intenta parsear
              : (json['latitude'] as num).toDouble()), // Si es num, convierte a double
      longitude: json['longitude'] == null
          ? null
          : (json['longitude'] is String
              ? double.tryParse(json['longitude'] as String) // Si es String, intenta parsear
              : (json['longitude'] as num).toDouble()), // Si es num, convierte a double
      isActive: json['is_active'] as bool, // Conversión explícita
      createdAt: DateTime.parse(json['created_at'] as String), // Conversión explícita
      updatedAt: DateTime.parse(json['updated_at'] as String), // Conversión explícita
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

// También es buena práctica asegurar las conversiones en Country
class Country {
  final int id;
  final String name;
  final String code;
  final String continent;

  Country({
    required this.id,
    required this.name,
    required this.code,
    required this.continent,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'] as int, // Conversión explícita
      name: json['name'] as String, // Conversión explícita
      code: json['code'] as String, // Conversión explícita
      continent: json['continent'] as String, // Conversión explícita
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'continent': continent,
    };
  }
}
