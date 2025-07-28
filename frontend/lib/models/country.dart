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
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      continent: json['continent'] as String? ?? '',
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

  @override
  String toString() {
    return '$name ($code)';
  }
}
