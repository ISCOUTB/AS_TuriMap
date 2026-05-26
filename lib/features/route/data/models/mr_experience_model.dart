import 'package:turimap/features/route/domain/entities/mr_experience.dart';

class MrExperienceModel extends MrExperience {
  const MrExperienceModel({
    required super.id,
    required super.puntoRutaId,
    required super.titulo,
    required super.tipo,
    super.descripcion,
    super.assetUrl,
    super.thumbnailUrl,
    super.disponible,
    super.radioActivacionM,
    super.duracionSegundos,
  });

  factory MrExperienceModel.fromSupabase(Map<String, dynamic> json) {
    return MrExperienceModel(
      id: json['id'] as String,
      puntoRutaId: json['punto_ruta_id'] as String,
      titulo: json['titulo'] as String,
      tipo: json['tipo'] as String,
      descripcion: json['descripcion'] as String?,
      assetUrl: json['asset_url'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      disponible: json['disponible'] as bool? ?? false,
      radioActivacionM:
          (json['radio_activacion_m'] as num?)?.toDouble() ?? 50.0,
      duracionSegundos: json['duracion_segundos'] as int?,
    );
  }
}