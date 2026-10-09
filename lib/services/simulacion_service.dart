/// Servicio de lógica de simulación ambiental.
///
/// Modelo de ESTIMACIÓN por regresión lineal simple, calculado
/// sobre las 568 mediciones reales de `assets/data/air_quality.db`
/// (sensor SEN66, sala 601, 01/04/2026).
///
///   CO₂_estimado = intercepto + pendiente · temperatura
///
/// IMPORTANTE: es un modelo estadístico descriptivo (R² ≈ 0.46),
/// NO una relación causal. Solo se usa la temperatura porque en los
/// datos reales temperatura y humedad están casi perfectamente
/// colineales (r = -0.979); incluir ambas haría el modelo inestable.
class SimulacionService {
  /// Intersección (a) de la recta de mínimos cuadrados: CO₂ = a + b·temp.
  static const double intercepto = -1185.07;

  /// Pendiente (b): ppm de CO₂ por cada °C adicional.
  static const double pendienteTemperatura = 70.09;

  /// Coeficiente de determinación del modelo (bondad de ajuste).
  static const double r2 = 0.463;

  // Rangos observados en los datos reales, usados para acotar
  // la entrada y evitar estimaciones absurdas fuera de rango.
  static const double tempMinDatos = 20.3;
  static const double tempMaxDatos = 29.3;
  static const double co2MinDatos = 386.0;
  static const double co2MaxDatos = 1104.0;

  // Márgenes razonables para la entrada del simulador (un poco más
  // amplios que lo observado, pero sin salirnos de lo plausible).
  static const double tempMinEntrada = 15.0;
  static const double tempMaxEntrada = 35.0;
  static const double co2MinSalida = 300.0; // ~aire exterior
  static const double co2MaxSalida = 2000.0; // límite prudente interior

  /// Estima el CO₂ (ppm) a partir de una temperatura (°C).
  ///
  /// El resultado se limita a [co2MinSalida, co2MaxSalida] para no
  /// devolver valores absurdos fuera del rango físico razonable.
  double estimarCo2(double temperatura) {
    final bruto = intercepto + pendienteTemperatura * temperatura;
    return bruto.clamp(co2MinSalida, co2MaxSalida);
  }
}
