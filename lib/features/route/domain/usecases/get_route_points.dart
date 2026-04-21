import 'package:turimap/core/usecases/usecase.dart';
import '../entities/route_point.dart';
import '../repositories/i_route_repository.dart';

class GetRoutePoints implements UseCase<List<RoutePoint>, NoParams> {
  final IRouteRepository repository;
  const GetRoutePoints(this.repository);

  @override
  Future<List<RoutePoint>> call(NoParams params) =>
      repository.getRoutePoints();
}