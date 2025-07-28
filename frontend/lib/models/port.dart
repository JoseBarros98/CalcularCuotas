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
      id: json['id'],
      name: json['name'],
      code: json['code'],
      continent: json['continent'],
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
      id: json['id'],
      name: json['name'],
      code: json['code'],
      country: Country.fromJson(json['country']),
      city: json['city'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
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