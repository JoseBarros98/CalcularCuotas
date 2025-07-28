import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/shipping_route.dart';

class ShippingRouteService {
  final String _baseUrl = 'http://localhost:8000'; // Ajusta según tu entorno

  Future<List<ShippingRoute>> getShippingRoutes() async {
    final response = await http.get(Uri.parse('$_baseUrl/api/v1/shipping-routes/'));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      List<dynamic> results = jsonResponse['results'];
      return results.map((sr) => ShippingRoute.fromJson(sr)).toList();
    } else {
      throw Exception('Failed to load shipping routes: ${response.statusCode} ${response.body}');
    }
  }

  Future<ShippingRoute> getShippingRoute(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/api/v1/shipping-routes/$id/'));

    if (response.statusCode == 200) {
      return ShippingRoute.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to load shipping route: ${response.statusCode} ${response.body}');
    }
  }

  Future<ShippingRoute> createShippingRoute(ShippingRoute shippingRoute) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/shipping-routes/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(shippingRoute.toJson()),
    );

    if (response.statusCode == 201) {
      return ShippingRoute.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to create shipping route: ${response.statusCode} ${response.body}');
    }
  }

  Future<ShippingRoute> updateShippingRoute(ShippingRoute shippingRoute) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/v1/shipping-routes/${shippingRoute.id}/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(shippingRoute.toJson()),
    );

    if (response.statusCode == 200) {
      return ShippingRoute.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to update shipping route: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> deleteShippingRoute(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/api/v1/shipping-routes/$id/'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete shipping route: ${response.statusCode} ${response.body}');
    }
  }
}
