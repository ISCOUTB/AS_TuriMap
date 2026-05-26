import 'package:turimap/features/content/domain/entities/fototeca_item.dart';

class FototecaItemModel extends FototecaItem {
  const FototecaItemModel({
    required super.id,
    required super.titulo,
    required super.urlImagen,
    super.descripcion,
    super.autor,
    super.fuente,
    super.anioAprox,
    super.urlThumbnail,
    super.tags,
    super.puntoRutaId,
    super.epocaHistorica,
    super.esDestacada,
  });

  factory FototecaItemModel.fromSupabase(Map<String, dynamic> json) {
    return FototecaItemModel(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      urlImagen: json['url_imagen'] as String,
      descripcion: json['descripcion'] as String?,
      autor: json['autor'] as String?,
      fuente: json['fuente'] as String?,
      anioAprox: json['anio_aprox'] as int?,
      urlThumbnail: json['url_thumbnail'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>(),
      puntoRutaId: json['punto_ruta_id'] as String?,
      epocaHistorica: json['epoca_historica'] as String?,
      esDestacada: json['es_destacada'] as bool? ?? false,
    );
  }
}