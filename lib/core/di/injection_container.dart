import 'package:get_it/get_it.dart';
import 'package:turimap/features/content/data/datasource/content_remote_datasource.dart';
import 'package:turimap/features/content/data/repositories/content_repository_impl.dart';
import 'package:turimap/features/content/domain/repositories/i_content_repository.dart';
import 'package:turimap/features/content/domain/usecases/get_fototeca_by_punto.dart';
import 'package:turimap/features/route/data/datasources/route_remote_datasource.dart';
import 'package:turimap/features/route/data/repositories/route_repository_impl.dart';
import 'package:turimap/features/route/domain/repositories/i_route_repository.dart';
import 'package:turimap/features/route/domain/usecases/get_route_points.dart';
import 'package:turimap/features/route/presentation/bloc/route_bloc.dart';
import 'package:turimap/features/content/presentation/bloc/fototeca_bloc.dart';
final sl = GetIt.instance;

Future<void> initDependencies() async {

  sl.registerFactory(() => FototecaBloc(getFototecaByPunto: sl()));
  // ── BLoC ──────────────────────────────────────────
  sl.registerFactory(() => RouteBloc(getRoutePoints: sl()));

  // ── Use Cases ─────────────────────────────────────
  sl.registerLazySingleton(() => GetRoutePoints(sl()));
  sl.registerLazySingleton(() => GetFototecaByPunto(sl()));

  // ── Repositories ──────────────────────────────────
  sl.registerLazySingleton<IRouteRepository>(
    () => RouteRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<IContentRepository>(
    () => ContentRepositoryImpl(sl()),
  );

  // ── Datasources ───────────────────────────────────
  sl.registerLazySingleton<IRouteRemoteDatasource>(
    () => RouteRemoteDatasourceImpl(),
  );
  sl.registerLazySingleton<IContentRemoteDatasource>(
    () => ContentRemoteDatasourceImpl(),
  );
}