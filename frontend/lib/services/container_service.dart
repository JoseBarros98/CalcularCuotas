import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/container.dart';

class ContainerService {
  final String _baseUrl = 'http://localhost:8000';

  // --- ContainerType CRUD ---
  Future<List<ContainerType>> getContainerTypes() async {
    final response = await http.get(Uri.parse('$_baseUrl/api/v1/container-types/'));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      List<dynamic> results = jsonResponse['results'];
      return results.map((ct) => ContainerType.fromJson(ct)).toList();
    } else {
      throw Exception('Failed to load container types: ${response.statusCode} ${response.body}');
    }
  }

  Future<ContainerType> getContainerType(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/api/v1/container-types/$id/'));

    if (response.statusCode == 200) {
      return ContainerType.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to load container type: ${response.statusCode} ${response.body}');
    }
  }

  Future<ContainerType> createContainerType(ContainerType containerType) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/container-types/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(containerType.toJson()),
    );

    if (response.statusCode == 201) {
      return ContainerType.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to create container type: ${response.statusCode} ${response.body}');
    }
  }

  Future<ContainerType> updateContainerType(ContainerType containerType) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/v1/container-types/${containerType.id}/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(containerType.toJson()),
    );

    if (response.statusCode == 200) {
      return ContainerType.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to update container type: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> deleteContainerType(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/api/v1/container-types/$id/'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete container type: ${response.statusCode} ${response.body}');
    }
  }

  // --- CargoType CRUD ---
  Future<List<CargoType>> getCargoTypes() async {
    final response = await http.get(Uri.parse('$_baseUrl/api/v1/cargo-types/'));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      List<dynamic> results = jsonResponse['results'];
      return results.map((ct) => CargoType.fromJson(ct)).toList();
    } else {
      throw Exception('Failed to load cargo types: ${response.statusCode} ${response.body}');
    }
  }

  Future<CargoType> getCargoType(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/api/v1/cargo-types/$id/'));

    if (response.statusCode == 200) {
      return CargoType.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to load cargo type: ${response.statusCode} ${response.body}');
    }
  }

  Future<CargoType> createCargoType(CargoType cargoType) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/cargo-types/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(cargoType.toJson()),
    );

    if (response.statusCode == 201) {
      return CargoType.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to create cargo type: ${response.statusCode} ${response.body}');
    }
  }

  Future<CargoType> updateCargoType(CargoType cargoType) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/v1/cargo-types/${cargoType.id}/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(cargoType.toJson()),
    );

    if (response.statusCode == 200) {
      return CargoType.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to update cargo type: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> deleteCargoType(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/api/v1/cargo-types/$id/'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete cargo type: ${response.statusCode} ${response.body}');
    }
  }
}
