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
      id: json['id'],
      name: json['name'],
      size: json['size'],
      type: json['type'],
      maxWeight: (json['max_weight'] as num).toDouble(),
      internalLength: (json['internal_length'] as num).toDouble(),
      internalWidth: (json['internal_width'] as num).toDouble(),
      internalHeight: (json['internal_height'] as num).toDouble(),
      volume: (json['volume'] as num).toDouble(),
      isActive: json['is_active'],
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
    return '$name (${size}\' ${type})';
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
      id: json['id'],
      name: json['name'],
      description: json['description'],
      hazardous: json['hazardous'],
      requiresSpecialHandling: json['requires_special_handling'],
      densityFactor: (json['density_factor'] as num).toDouble(),
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