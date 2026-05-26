import 'package:turimap/features/route/domain/entities/route_point.dart';

class RoutePointModel extends RoutePoint {
  const RoutePointModel({
    required super.id,
    required super.name,
    required super.description,
    required super.latitude,
    required super.longitude,
    required super.mrExperienceId,
    required super.order,
    super.imageUrl,
    super.categoria,
    super.categoriaColor,
    super.patrimonioUnesco,
    super.epocaHistorica,
    super.mrDisponible,
    super.totalFotos,
  });

  factory RoutePointModel.fromSupabase(Map<String, dynamic> json) {
    return RoutePointModel(
      id: json['id'] as String,
      name: json['nombre'] as String,
      description: json['descripcion_corta'] as String,
      latitude: (json['latitud'] as num).toDouble(),
      longitude: (json['longitud'] as num).toDouble(),
      mrExperienceId: json['mr_id'] as String? ?? '',
      order: json['orden'] as int,
      imageUrl: json['imagen_principal_url'] as String?,
      categoria: json['categoria'] as String?,
      categoriaColor: json['categoria_color'] as String?,
      patrimonioUnesco: json['patrimonio_unesco'] as bool? ?? false,
      epocaHistorica: json['epoca_historica'] as String?,
      mrDisponible: json['mr_disponible'] as bool? ?? false,
      totalFotos: json['total_fotos'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': name,
    'descripcion_corta': description,
    'latitud': latitude,
    'longitud': longitude,
    'mr_id': mrExperienceId,
    'orden': order,
  };
}