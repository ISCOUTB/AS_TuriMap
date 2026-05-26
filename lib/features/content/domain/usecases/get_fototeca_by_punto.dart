import 'package:turimap/core/usecases/usecase.dart';
import '../entities/fototeca_item.dart';
import '../repositories/i_content_repository.dart';

class GetFototecaByPunto implements UseCase<List<FototecaItem>, String> {
  final IContentRepository repository;
  const GetFototecaByPunto(this.repository);

  @override
  Future<List<FototecaItem>> call(String puntoRutaId) =>
      repository.getFototecaByPunto(puntoRutaId);
}