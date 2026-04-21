import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:turimap/core/utils/constants.dart';
import 'package:turimap/features/route/domain/entities/route_point.dart';
import 'package:turimap/features/route/presentation/bloc/route_bloc.dart';
import 'package:turimap/features/route/presentation/bloc/route_event.dart';
import 'package:turimap/features/route/presentation/bloc/route_state.dart';
import 'package:turimap/features/route/presentation/widgets/route_point_card.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  RoutePoint? _selectedPoint;

  @override
  void initState() {
    super.initState();
    // Disparamos el evento apenas abre la pantalla
    context.read<RouteBloc>().add(const LoadRoutePoints());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<RouteBloc, RouteState>(
        builder: (context, state) {
          if (state is RouteLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando ruta histórica...'),
                ],
              ),
            );
          }

          if (state is RouteError) {
            return Center(child: Text(state.message));
          }

          if (state is RouteLoaded) {
            return Stack(
              children: [
                _buildMap(state.points),
                _buildHeader(),
                if (_selectedPoint != null)
                  _buildPointCard(_selectedPoint!),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildMap(List<RoutePoint> points) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(
          AppConstants.cartagenaLat,
          AppConstants.cartagenaLng,
        ),
        initialZoom: AppConstants.initialZoom,
        onTap: (_, __) => setState(() => _selectedPoint = null),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.tupimap.app',
        ),
        // Línea que conecta los puntos de la ruta
        PolylineLayer(
          polylines: [
            Polyline(
              points: points
                  .map((p) => LatLng(p.latitude, p.longitude))
                  .toList(),
              strokeWidth: 3,
              color: const Color(0xFF006B75),
            ),
          ],
        ),
        // Marcadores de cada punto
        MarkerLayer(
          markers: points.map((point) => _buildMarker(point)).toList(),
        ),
      ],
    );
  }

  Marker _buildMarker(RoutePoint point) {
    final isSelected = _selectedPoint?.id == point.id;
    return Marker(
      point: LatLng(point.latitude, point.longitude),
      width: 44,
      height: 44,
      child: GestureDetector(
        onTap: () => setState(() => _selectedPoint = point),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF006B75)
                : const Color(0xFF006B75).withOpacity(0.85),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '${point.order}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8,
          bottom: 12,
          left: 16,
          right: 16,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF006B75),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.map_outlined, color: Colors.white, size: 24),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TupiMap',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Ruta histórica · Centro de Cartagena',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointCard(RoutePoint point) {
    return Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: RoutePointCard(point: point),
    );
  }
}