import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turimap/features/content/data/models/fototeca_item_model.dart';
import 'package:turimap/features/content/domain/entities/fototeca_item.dart';

abstract class IContentRemoteDatasource {
  Future<List<FototecaItem>> getFototecaByPunto(String puntoRutaId);
  Future<FototecaItem> getFotoById(String id);
}

class ContentRemoteDatasourceImpl implements IContentRemoteDatasource {
  final SupabaseClient _client;

  ContentRemoteDatasourceImpl({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<List<FototecaItem>> getFototecaByPunto(String puntoRutaId) async {
    final response = await _client
        .from('fototeca')
        .select()
        .eq('punto_ruta_id', puntoRutaId)
        .order('anio_aprox', ascending: true);

    return (response as List)
        .map((json) => FototecaItemModel.fromSupabase(json))
        .toList();
  }

  @override
  Future<FototecaItem> getFotoById(String id) async {
    final response = await _client
        .from('fototeca')
        .select()
        .eq('id', id)
        .single();

    return FototecaItemModel.fromSupabase(response);
  }
}