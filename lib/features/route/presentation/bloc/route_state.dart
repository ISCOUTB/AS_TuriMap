import 'package:equatable/equatable.dart';
import '../../domain/entities/route_point.dart';

// Cada estado = una situación posible de la pantalla
abstract class RouteState extends Equatable {
  const RouteState();
  @override
  List<Object?> get props => [];
}

class RouteInitial extends RouteState {}

class RouteLoading extends RouteState {}

class RouteLoaded extends RouteState {
  final List<RoutePoint> points;
  const RouteLoaded(this.points);
  @override
  List<Object?> get props => [points];
}

class RouteError extends RouteState {
  final String message;
  const RouteError(this.message);
  @override
  List<Object?> get props => [message];
}