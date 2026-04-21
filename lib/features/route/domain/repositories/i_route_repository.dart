import '../entities/route_point.dart';

abstract class IRouteRepository {
  Future<List<RoutePoint>> getRoutePoints();
  Future<RoutePoint> getRoutePointById(String id);
}