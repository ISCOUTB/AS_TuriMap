import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turimap/features/route/domain/entities/route_point.dart';
import 'package:turimap/features/route/domain/entities/mr_experience.dart';
import 'package:turimap/features/content/domain/entities/fototeca_item.dart';
import 'package:turimap/features/route/data/models/route_point_model.dart';
import 'package:turimap/features/route/data/models/mr_experience_model.dart';
import 'package:turimap/features/content/data/models/fototeca_item_model.dart';

abstract class IRouteRemoteDatasource {
  Future<List<RoutePoint>> getRoutePoints();
  Future<List<RoutePoint>> getNearbyPoints({
    required double lat,
    required double lng,
    int radioMetros = 200,
  });
  Future<MrExperience?> getMrExperience(String puntoId);
  Future<List<FototecaItem>> getFototecaByPunto(String puntoId);
  Future<void> registrarVisita({
    required String usuarioId,
    required String puntoId,
    bool mrCompletado = false,
  });
}

class RouteRemoteDatasourceImpl implements IRouteRemoteDatasource {
  final SupabaseClient _client;

  RouteRemoteDatasourceImpl({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<List<RoutePoint>> getRoutePoints() async {
    final response = await _client
        .from('v_puntos_completos')
        .select()
        .order('orden', ascending: true);

    return (response as List)
        .map((json) => RoutePointModel.fromSupabase(json))
        .toList();
  }

  @override
  Future<List<RoutePoint>> getNearbyPoints({
    required double lat,
    required double lng,
    int radioMetros = 200,
  }) async {
    final response = await _client.rpc(
      'puntos_cercanos',
      params: {'p_lat': lat, 'p_lng': lng, 'p_radio': radioMetros},
    );

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