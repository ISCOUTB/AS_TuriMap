import 'package:equatable/equatable.dart';

class RoutePoint extends Equatable {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String mrExperienceId;
  final int order;

  const RoutePoint({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.mrExperienceId,
    required this.order,
  });

  @override
  List<Object?> get props =>
      [id, name, description, latitude, longitude, mrExperienceId, order];
}