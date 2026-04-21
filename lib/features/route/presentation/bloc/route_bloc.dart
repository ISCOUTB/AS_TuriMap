import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turimap/core/usecases/usecase.dart';
import '../../domain/usecases/get_route_points.dart';
import 'route_event.dart';
import 'route_state.dart';

// El BLoC es el patrón Observer:
// - Escucha eventos (acciones del usuario)
// - Emite estados (cómo debe verse la pantalla)
// La pantalla NUNCA llama directamente al UseCase
class RouteBloc extends Bloc<RouteEvent, RouteState> {
  final GetRoutePoints getRoutePoints;

  RouteBloc({required this.getRoutePoints}) : super(RouteInitial()) {
    on<LoadRoutePoints>(_onLoadRoutePoints);
  }

  Future<void> _onLoadRoutePoints(
    LoadRoutePoints event,
    Emitter<RouteState> emit,
  ) async {
    emit(RouteLoading());
    try {
      final points = await getRoutePoints(const NoParams());
      emit(RouteLoaded(points));
    } catch (e) {
      emit(RouteError('No se pudieron cargar los puntos de la ruta'));
    }
  }
}