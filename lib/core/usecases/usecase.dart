abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

/// Usar cuando un caso de uso no necesita parámetros.
/// Ejemplo: "obtener todas las rutas disponibles"
class NoParams {
  const NoParams();
}