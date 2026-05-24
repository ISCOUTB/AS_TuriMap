import 'package:equatable/equatable.dart';

class MrExperience extends Equatable {
  final String id;
  final String puntoRutaId;
  final String titulo;
  final String tipo;           // 'ar_overlay','3d_model','video_360', etc.
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
  List<Object?> get props => [id, puntoRutaId, titulo, tipo, disponible];
}
