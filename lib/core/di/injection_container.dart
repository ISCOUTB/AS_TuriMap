import 'package:get_it/get_it.dart';
import 'package:turimap/features/route/data/datasources/route_local_datasource.dart';
import 'package:turimap/features/route/data/repositories/route_repository_impl.dart';
import 'package:turimap/features/route/domain/repositories/i_route_repository.dart';
import 'package:turimap/features/route/domain/usecases/get_route_points.dart';
import 'package:turimap/features/route/presentation/bloc/route_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // BLoC
  sl.registerFactory(() => RouteBloc(getRoutePoints: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetRoutePoints(sl()));

  // Repositories — registrado como la INTERFAZ, no la implementación
  // Esto es Dependency Inversion en acción: GetRoutePoints pide IRouteRepository
  // y GetIt le entrega RouteRepositoryImpl sin que nadie lo sepa
  sl.registerLazySingleton<IRouteRepository>(
    () => RouteRepositoryImpl(sl()),
  );

  // Data sources
  sl.registerLazySingleton<IRouteLocalDatasource>(
    () => RouteLocalDatasourceImpl(),
  );
}