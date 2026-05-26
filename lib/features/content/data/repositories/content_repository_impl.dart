import 'package:turimap/features/content/domain/entities/fototeca_item.dart';
import 'package:turimap/features/content/domain/repositories/i_content_repository.dart';
import '../datasource/content_remote_datasource.dart';

class ContentRepositoryImpl implements IContentRepository {
  final IContentRemoteDatasource remoteDatasource;
  const ContentRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<FototecaItem>> getFototecaByPunto(String puntoRutaId) =>
      remoteDatasource.getFototecaByPunto(puntoRutaId);

  @override
  Future<FototecaItem> getFotoById(String id) =>
      remoteDatasource.getFotoById(id);

  @override
  Future<void> syncContent() async {
    // Por implementar cuando haya caché local
  }
}