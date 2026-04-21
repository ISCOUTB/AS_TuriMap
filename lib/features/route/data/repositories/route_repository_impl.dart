import '../../domain/entities/route_point.dart';
import '../../domain/repositories/i_route_repository.dart';
import '../datasources/route_local_datasource.dart';

// Esta clase implementa el contrato del dominio.
// SOLID-L: puede usarse en cualquier lugar donde se espere IRouteRepository.
class RouteRepositoryImpl implements IRouteRepository {
  final IRouteLocalDatasource localDatasource;
  const RouteRepositoryImpl(this.localDatasource);

  @override
  Future<List<RoutePoint>> getRoutePoints() =>
      localDatasource.getRoutePoints();

  @override
  Future<RoutePoint> getRoutePointById(String id) async {
    final points = await localDatasource.getRoutePoints();
    return points.firstWhere((p) => p.id == id);
  }
}