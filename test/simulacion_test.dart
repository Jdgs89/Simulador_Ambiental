// Pruebas unitarias del modelo de simulación de CO₂.
//
// Verifican la fórmula de regresión y el recorte de valores
// fuera de rango, sin depender de la base de datos.

import 'package:flutter_test/flutter_test.dart';
import 'package:simulador_ambiental/services/simulacion_service.dart';

void main() {
  final servicio = SimulacionService();

  test('La estimación sigue la recta a + b·temp dentro del rango', () {
    // 25 °C -> -1185.07 + 70.09*25 = 567.18 ppm
    expect(servicio.estimarCo2(25.0), closeTo(567.18, 0.01));
    // La media de los datos (27.0 °C) debe dar un valor cercano a la
    // media real de CO₂ (~708 ppm).
    expect(servicio.estimarCo2(27.0), closeTo(708, 20));
  });

  test('Temperaturas mayores estiman más CO₂ (pendiente positiva)', () {
    expect(servicio.estimarCo2(30.0), greaterThan(servicio.estimarCo2(20.0)));
  });

  test('El resultado se acota para evitar valores absurdos', () {
    // Muy frío: no debe bajar del mínimo de salida.
    expect(servicio.estimarCo2(-50), SimulacionService.co2MinSalida);
    // Muy caliente: no debe superar el máximo de salida.
    expect(servicio.estimarCo2(100), SimulacionService.co2MaxSalida);
  });
}
