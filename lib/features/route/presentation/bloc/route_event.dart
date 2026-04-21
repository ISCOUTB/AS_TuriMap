import 'package:equatable/equatable.dart';

abstract class RouteEvent extends Equatable {
  const RouteEvent();
  @override
  List<Object?> get props => [];
}

class LoadRoutePoints extends RouteEvent {
  const LoadRoutePoints();
}