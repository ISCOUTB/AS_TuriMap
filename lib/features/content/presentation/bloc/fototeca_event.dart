import 'package:equatable/equatable.dart';

abstract class FototecaEvent extends Equatable {
  const FototecaEvent();
  @override
  List<Object?> get props => [];
}

class LoadFototeca extends FototecaEvent {
  final String puntoRutaId;
  const LoadFototeca(this.puntoRutaId);
  @override
  List<Object?> get props => [puntoRutaId];
}