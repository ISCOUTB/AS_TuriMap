import 'package:equatable/equatable.dart';

class RoutePoint extends Equatable {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String mrExperienceId;
  final int order;

  // Campos nuevos (del schema completo)
  final String? imageUrl;
  final String? categoria;
  final String? categoriaColor;
  final bool patrimonioUnesco;
  final String? epocaHistorica;
  final bool mrDisponible;
  final int totalFotos;

  const RoutePoint({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.mrExperienceId,
    required this.order,
    this.imageUrl,
    this.categoria,
    this.categoriaColor,
    this.patrimonioUnesco = false,
    this.epocaHistorica,
    this.mrDisponible = false,
    this.totalFotos = 0,
  });

  @override
  List<Object?> get props => [
        id, name, description, latitude, longitude,
        mrExperienceId, order, patrimonioUnesco, mrDisponible,
      ];
}
