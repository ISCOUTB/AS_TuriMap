import 'package:equatable/equatable.dart';
import 'package:turimap/features/content/domain/entities/fototeca_item.dart';

abstract class FototecaState extends Equatable {
  const FototecaState();
  @override
  List<Object?> get props => [];
}

class FototecaInitial extends FototecaState {}
class FototecaLoading extends FototecaState {}

class FototecaLoaded extends FototecaState {
  final List<FototecaItem> photos;
  const FototecaLoaded(this.photos);
  @override
  List<Object?> get props => [photos];
}

class FototecaError extends FototecaState {
  final String message;
  const FototecaError(this.message);
  @override
  List<Object?> get props => [message];
}