import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turimap/core/di/injection_container.dart' as di;
import 'package:turimap/features/content/presentation/bloc/fototeca_bloc.dart';
import 'package:turimap/features/content/presentation/bloc/fototeca_event.dart';
import 'package:turimap/features/content/presentation/bloc/fototeca_state.dart';
import 'package:turimap/features/route/domain/entities/route_point.dart';

class PointDetailPage extends StatelessWidget {
  final RoutePoint point;
  const PointDetailPage({super.key, required this.point});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<FototecaBloc>()
        ..add(LoadFototeca(point.id)),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(child: _buildInfo(context)),
            SliverToBoxAdapter(child: _buildMrButton(context)),
            SliverToBoxAdapter(child: _buildFototecaSection()),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: const Color(0xFF006B75),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          point.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF004D57), Color(0xFF006B75)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white54, width: 2),
                ),
                child: Center(
                  child: Text(
                    '${point.order}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (point.categoria != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF006B75).withAlpha(20),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF006B75)),
              ),
              child: Text(
                point.categoria!,
                style: const TextStyle(
                  color: Color(0xFF006B75),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (point.patrimonioUnesco)
            const Row(
              children: [
                Icon(Icons.verified, color: Color(0xFF1A3C6E), size: 16),
                SizedBox(width: 4),
                Text(
                  'Patrimonio UNESCO',
                  style: TextStyle(
                    color: Color(0xFF1A3C6E),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          Text(
            point.description,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[800],
              height: 1.6,
            ),
          ),
          if (point.epocaHistorica != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.history, color: Color(0xFF006B75), size: 18),
                const SizedBox(width: 8),
                Text(
                  point.epocaHistorica!,
                  style: const TextStyle(
                    color: Color(0xFF006B75),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMrButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF006B75),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.view_in_ar),
          label: Text(
            point.mrDisponible
                ? 'Iniciar Experiencia MR'
                : 'Experiencia MR — Próximamente',
          ),
          onPressed: point.mrDisponible
              ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Iniciando experiencia MR...')),
                  );
                }
              : null,
        ),
      ),
    );
  }

  Widget _buildFototecaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(
            children: [
              Icon(Icons.photo_library, color: Color(0xFF006B75)),
              SizedBox(width: 8),
              Text(
                'Fototeca UTB',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
        ),
        BlocBuilder<FototecaBloc, FototecaState>(
          builder: (context, state) {
            if (state is FototecaLoading) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (state is FototecaLoaded) {
              if (state.photos.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'No hay fotografías históricas disponibles aún',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }
              return SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.photos.length,
                  itemBuilder: (context, index) {
                    final foto = state.photos[index];
                    return Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 12, bottom: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[200],
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(20),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: foto.urlThumbnail != null
                                  ? Image.network(
                                      foto.urlThumbnail!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder: (_, __, ___) =>
                                          _photoPlaceholder(),
                                    )
                                  : _photoPlaceholder(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  foto.titulo,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (foto.anioAprox != null)
                                  Text(
                                    '${foto.anioAprox}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }
            if (state is FototecaError) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Center(child: Text(state.message)),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _photoPlaceholder() {
    return Container(
      color: const Color(0xFF006B75).withAlpha(20),
      child: const Center(
        child: Icon(Icons.image, color: Color(0xFF006B75), size: 40),
      ),
    );
  }
}