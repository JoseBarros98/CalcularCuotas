import 'package:frontend/models/container.dart';
import 'package:frontend/services/api_service.dart';

class ContainerService {
  final ApiService _apiService = ApiService();

  Future<List<ContainerType>> getContainerTypes() async {
    return await _apiService.fetchList<ContainerType>('container-types', ContainerType.fromJson);
  }

  Future<List<CargoType>> getCargoTypes() async {
    return await _apiService.fetchList<CargoType>('cargo-types', CargoType.fromJson);
  }
}