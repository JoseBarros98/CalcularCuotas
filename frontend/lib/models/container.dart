class ContainerType {
  final int id;
  final String name;
  final String size;
  final String type;
  final double maxWeight;
  final double internalLength;
  final double internalWidth;
  final double internalHeight;
  final double volume;
  final bool isActive;

  ContainerType({
    required this.id,
    required this.name,
    required this.size,
    required this.type,
    required this.maxWeight,
    required this.internalLength,
    required this.internalWidth,
    required this.internalHeight,
    required this.volume,
    required this.isActive,
  });

  factory ContainerType.fromJson(Map<String, dynamic> json) {
    return ContainerType(
      id: json['id'] as int, // Asegurar que es int
      name: json['name'] as String? ?? '', // Manejar null para String
      size: json['size'] as String? ?? '', // Manejar null para String
      type: json['type'] as String? ?? '', // Manejar null para String
      maxWeight: json['max_weight'] == null
          ? 0.0 // Valor por defecto si es null
          : (json['max_weight'] is String
              ? double.tryParse(json['max_weight'] as String) ?? 0.0 // Si es String, parsear
              : (json['max_weight'] as num).toDouble()), // Si es num, convertir
      internalLength: json['internal_length'] == null
          ? 0.0
          : (json['internal_length'] is String
              ? double.tryParse(json['internal_length'] as String) ?? 0.0
              : (json['internal_length'] as num).toDouble()),
      internalWidth: json['internal_width'] == null
          ? 0.0
          : (json['internal_width'] is String
              ? double.tryParse(json['internal_width'] as String) ?? 0.0
              : (json['internal_width'] as num).toDouble()),
      internalHeight: json['internal_height'] == null
          ? 0.0
          : (json['internal_height'] is String
              ? double.tryParse(json['internal_height'] as String) ?? 0.0
              : (json['internal_height'] as num).toDouble()),
      volume: json['volume'] == null
          ? 0.0
          : (json['volume'] is String
              ? double.tryParse(json['volume'] as String) ?? 0.0
              : (json['volume'] as num).toDouble()),
      isActive: json['is_active'] as bool? ?? false, // Manejar null para bool
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'size': size,
      'type': type,
      'max_weight': maxWeight,
      'internal_length': internalLength,
      'internal_width': internalWidth,
      'internal_height': internalHeight,
      'volume': volume,
      'is_active': isActive,
    };
  }

  @override
  String toString() {
    return '$name ($size\' $type)';
  }
}

class CargoType {
  final int id;
  final String name;
  final String description;
  final bool hazardous;
  final bool requiresSpecialHandling;
  final double densityFactor;

  CargoType({
    required this.id,
    required this.name,
    required this.description,
    required this.hazardous,
    required this.requiresSpecialHandling,
    required this.densityFactor,
  });

  factory CargoType.fromJson(Map<String, dynamic> json) {
    return CargoType(
      id: json['id'] as int, // Asegurar que es int
      name: json['name'] as String? ?? '', // Manejar null para String
      description: json['description'] as String? ?? '', // Manejar null para String
      hazardous: json['hazardous'] as bool? ?? false, // Manejar null para bool
      requiresSpecialHandling: json['requires_special_handling'] as bool? ?? false, // Manejar null para bool
      densityFactor: json['density_factor'] == null
          ? 0.0
          : (json['density_factor'] is String
              ? double.tryParse(json['density_factor'] as String) ?? 0.0
              : (json['density_factor'] as num).toDouble()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'hazardous': hazardous,
      'requires_special_handling': requiresSpecialHandling,
      'density_factor': densityFactor,
    };
  }

  @override
  String toString() {
    return name;
  }
}
