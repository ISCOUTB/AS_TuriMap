import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turimap/features/content/domain/usecases/get_fototeca_by_punto.dart';
import 'fototeca_event.dart';
import 'fototeca_state.dart';

class FototecaBloc extends Bloc<FototecaEvent, FototecaState> {
  final GetFototecaByPunto getFototecaByPunto;

  FototecaBloc({required this.getFototecaByPunto}) : super(FototecaInitial()) {
    on<LoadFototeca>(_onLoadFototeca);
  }

  Future<void> _onLoadFototeca(
    LoadFototeca event,
    Emitter<FototecaState> emit,
  ) async {
    emit(FototecaLoading());
    try {
      final photos = await getFototecaByPunto(event.puntoRutaId);
      emit(FototecaLoaded(photos));
    } catch (e) {
      emit(const FototecaError('No se pudo cargar la fototeca'));
    }
  }
}