import '../entities/fototeca_item.dart';

abstract class IContentRepository {
  Future<List<FototecaItem>> getFototecaByPunto(String puntoRutaId);
  Future<FototecaItem> getFotoById(String id);
  Future<void> syncContent();
}