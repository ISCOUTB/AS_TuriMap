import '../../domain/entities/route_point.dart';

// Por ahora usamos datos hardcodeados (mock).

abstract class IRouteLocalDatasource {
  Future<List<RoutePoint>> getRoutePoints();
}

class RouteLocalDatasourceImpl implements IRouteLocalDatasource {
  @override
  Future<List<RoutePoint>> getRoutePoints() async {
    // Simulamos latencia de red
    await Future.delayed(const Duration(milliseconds: 600));
    return _mockRoutePoints;
  }

  static const List<RoutePoint> _mockRoutePoints = [
    RoutePoint(
      id: '1',
      name: 'Puerta del Reloj',
      description: 'Entrada principal a la ciudad amurallada. '
          'Construida en el siglo XVII, era el acceso al centro comercial.',
      latitude: 10.4238,
      longitude: -75.5501,
      mrExperienceId: 'exp_1',
      order: 1,
    ),
    RoutePoint(
      id: '2',
      name: 'Plaza de los Coches',
      description: 'Antiguo mercado de esclavos, hoy plaza central '
          'rodeada de portales y el busto de Pedro de Heredia.',
      latitude: 10.4234,
      longitude: -75.5493,
      mrExperienceId: 'exp_2',
      order: 2,
    ),
    RoutePoint(
      id: '3',
      name: 'Catedral de Cartagena',
      description: 'Iniciada en 1575, es uno de los templos más '
          'antiguos de América del Sur. Patrimonio arquitectónico.',
      latitude: 10.4228,
      longitude: -75.5483,
      mrExperienceId: 'exp_3',
      order: 3,
    ),
    RoutePoint(
      id: '4',
      name: 'Plaza de Bolívar',
      description: 'Corazón histórico de Cartagena. Rodeada por '
          'la Catedral, el Palacio de la Inquisición y el Museo del Oro.',
      latitude: 10.4225,
      longitude: -75.5476,
      mrExperienceId: 'exp_4',
      order: 4,
    ),
    RoutePoint(
      id: '5',
      name: 'Castillo San Felipe',
      description: 'Fortaleza militar más grande construida por '
          'los españoles en América. Declarada Patrimonio UNESCO.',
      latitude: 10.4214,
      longitude: -75.5401,
      mrExperienceId: 'exp_5',
      order: 5,
    ),
  ];
}