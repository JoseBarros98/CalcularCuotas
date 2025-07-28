import 'package:frontend/models/port.dart';
import 'package:frontend/services/api_service.dart';

class PortService {
  final ApiService _apiService = ApiService();

  Future<List<Port>> getPorts() async {
    return await _apiService.fetchList<Port>('ports', Port.fromJson);
  }

  Future<List<Country>> getCountries() async {
    return await _apiService.fetchList<Country>('countries', Country.fromJson);
  }
}