// lib/features/route/data/datasources/route_remote_datasource.dart
//
// Datasource remoto: consulta la base de datos PostgreSQL vía Supabase REST API.
// Reemplaza el mock (route_local_datasource.dart) cuando el backend esté activo.
//
// Dependencia necesaria en pubspec.yaml:
//   supabase_flutter: ^2.3.0
// ─────────────────────────────────────────────────────────────────────────────

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/route_point.dart';
import '../../domain/entities/mr_experience.dart';
import '../../domain/entities/fototeca_item.dart';

// ─── Interfaz ────────────────────────────────────────────────────────────────

abstract class IRouteRemoteDatasource {
  /// Todos los puntos de la ruta ordenados por [orden].
  Future<List<RoutePoint>> getRoutePoints();

  /// Puntos dentro de [radioMetros] alrededor de la posición del usuario.
  Future<List<RoutePoint>> getNearbyPoints({
    required double lat,
    required double lng,
    int radioMetros = 200,
  });

  /// Experiencia MR asociada a un punto.
  Future<MrExperience?> getMrExperience(String puntoId);

  /// Fotografías históricas de un punto (fototeca UTB).
  Future<List<FototecaItem>> getFototecaByPunto(String puntoId);

  /// Registra que el usuario visitó un punto (y opcionalmente completó la MR).
  Future<void> registrarVisita({
    required String usuarioId,
    required String puntoId,
    bool mrCompletado = false,
  });
}

// ─── Implementación ──────────────────────────────────────────────────────────

class RouteRemoteDatasourceImpl implements IRouteRemoteDatasource {
  final SupabaseClient _client;

  RouteRemoteDatasourceImpl({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  // ── 1. Puntos de ruta ────────────────────────────────────────────────────

  @override
  Future<List<RoutePoint>> getRoutePoints() async {
    final response = await _client
        .from('v_puntos_completos')   // vista del schema que une todo
        .select()
        .order('orden', ascending: true);

    return (response as List)
        .map((json) => RoutePointModel.fromSupabase(json))
        .toList();
  }

  // ── 2. Puntos cercanos (llama a la función SQL puntos_cercanos) ───────────

  @override
  Future<List<RoutePoint>> getNearbyPoints({
    required double lat,
    required double lng,
    int radioMetros = 200,
  }) async {
    final response = await _client.rpc(
      'puntos_cercanos',
      params: {
        'p_lat': lat,
        'p_lng': lng,
        'p_radio': radioMetros,
      },
    );

    // Enriquecemos con los datos completos de cada punto
    final ids = (response as List).map((r) => r['id'] as String).toList();
    if (ids.isEmpty) return [];

    final full = await _client
        .from('v_puntos_completos')
        .select()
        .inFilter('id', ids);

    return (full as List)
        .map((json) => RoutePointModel.fromSupabase(json))
        .toList();
  }

  // ── 3. Experiencia MR ────────────────────────────────────────────────────

  @override
  Future<MrExperience?> getMrExperience(String puntoId) async {
    final response = await _client
        .from('experiencias_mr')
        .select()
        .eq('punto_ruta_id', puntoId)
        .maybeSingle();

    if (response == null) return null;
    return MrExperienceModel.fromSupabase(response);
  }

  // ── 4. Fototeca ──────────────────────────────────────────────────────────

  @override
  Future<List<FototecaItem>> getFototecaByPunto(String puntoId) async {
    final response = await _client
        .from('fototeca')
        .select()
        .eq('punto_ruta_id', puntoId)
        .order('anio_aprox', ascending: true);

    return (response as List)
        .map((json) => FototecaItemModel.fromSupabase(json))
        .toList();
  }

  // ── 5. Registrar visita ──────────────────────────────────────────────────

  @override
  Future<void> registrarVisita({
    required String usuarioId,
    required String puntoId,
    bool mrCompletado = false,
  }) async {
    await _client.rpc(
      'registrar_visita',
      params: {
        'p_usuario_id': usuarioId,
        'p_punto_id': puntoId,
        'p_mr_completado': mrCompletado,
      },
    );
  }
}

// =============================================================================
// MODELOS (Data layer — convierten JSON de Supabase a Entidades del dominio)
// =============================================================================

// ── RoutePointModel ──────────────────────────────────────────────────────────

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
}

// ── MrExperienceModel ────────────────────────────────────────────────────────

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
      radioActivacionM: (json['radio_activacion_m'] as num?)?.toDouble() ?? 50.0,
      duracionSegundos: json['duracion_segundos'] as int?,
    );
  }
}

// ── FototecaItemModel ────────────────────────────────────────────────────────

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
    );
  }
}
