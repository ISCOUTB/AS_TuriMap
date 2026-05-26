import 'package:equatable/equatable.dart';

class FototecaItem extends Equatable {
  final String id;
  final String titulo;
  final String urlImagen;
  final String? descripcion;
  final String? autor;
  final String? fuente;
  final int? anioAprox;
  final String? urlThumbnail;
  final List<String>? tags;
  final String? puntoRutaId;
  final String? epocaHistorica;
  final bool esDestacada;

  const FototecaItem({
    required this.id,
    required this.titulo,
    required this.urlImagen,
    this.descripcion,
    this.autor,
    this.fuente,
    this.anioAprox,
    this.urlThumbnail,
    this.tags,
    this.puntoRutaId,
    this.epocaHistorica,
    this.esDestacada = false,
  });

  @override
  List<Object?> get props => [id, titulo, puntoRutaId];
}