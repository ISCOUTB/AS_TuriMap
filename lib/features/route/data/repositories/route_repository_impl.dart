import 'package:turimap/features/route/data/datasources/route_remote_datasource.dart';
import 'package:turimap/features/route/domain/entities/route_point.dart';
import 'package:turimap/features/route/domain/entities/mr_experience.dart';
import 'package:turimap/features/route/domain/repositories/i_route_repository.dart';

class RouteRepositoryImpl implements IRouteRepository {
  final IRouteRemoteDatasource remoteDatasource;
  const RouteRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<RoutePoint>> getRoutePoints() =>
      remoteDatasource.getRoutePoints();

  @override
  Future<RoutePoint> getRoutePointById(String id) async {
    final points = await remoteDatasource.getRoutePoints();
    return points.firstWhere((p) => p.id == id);
  }

  Future<MrExperience?> getMrExperience(String puntoId) =>
      remoteDatasource.getMrExperience(puntoId);
}