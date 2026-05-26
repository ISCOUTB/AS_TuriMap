import 'package:equatable/equatable.dart';

// Tipos válidos según el CHECK del SQL
enum MrExperienceType {
  arOverlay,
  model3d,
  video360,
  imagenHistorica,
  audioGuiado,
  quiz,
}

class MrExperience extends Equatable {
  final String id;
  final String puntoRutaId;
  final String titulo;
  final String tipo;
  final String? descripcion;
  final String? assetUrl;
  final String? thumbnailUrl;
  final bool disponible;
  final double radioActivacionM;
  final int? duracionSegundos;

  const MrExperience({
    required this.id,
    required this.puntoRutaId,
    required this.titulo,
    required this.tipo,
    this.descripcion,
    this.assetUrl,
    this.thumbnailUrl,
    this.disponible = false,
    this.radioActivacionM = 50.0,
    this.duracionSegundos,
  });

  @override
  List<Object?> get props => [id, puntoRutaId, tipo];
}