/// Modelo de datos para una medición ambiental.
///
/// Corresponde a una fila de la tabla `mediciones` de
/// `assets/data/air_quality.db` (promedio de 1 minuto de las
/// lecturas del sensor SEN66 del grupo 601).
class Medicion {
  final int? id;
  final DateTime timestamp;
  final double temperature;
  final double humidity;
  final double co2;
  final double pm1;
  final double pm25;
  final double pm4;
  final double pm10;
  final double voc;
  final double nox;

  const Medicion({
    this.id,
    required this.timestamp,
    required this.temperature,
    required this.humidity,
    required this.co2,
    required this.pm1,
    required this.pm25,
    required this.pm4,
    required this.pm10,
    required this.voc,
    required this.nox,
  });

  factory Medicion.fromMap(Map<String, dynamic> map) {
    return Medicion(
      id: map['id'] as int?,
      timestamp: DateTime.parse(map['timestamp'] as String),
      temperature: (map['temperature'] as num).toDouble(),
      humidity: (map['humidity'] as num).toDouble(),
      co2: (map['co2'] as num).toDouble(),
      pm1: (map['pm1'] as num).toDouble(),
      pm25: (map['pm25'] as num).toDouble(),
      pm4: (map['pm4'] as num).toDouble(),
      pm10: (map['pm10'] as num).toDouble(),
      voc: (map['voc'] as num).toDouble(),
      nox: (map['nox'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'temperature': temperature,
      'humidity': humidity,
      'co2': co2,
      'pm1': pm1,
      'pm25': pm25,
      'pm4': pm4,
      'pm10': pm10,
      'voc': voc,
      'nox': nox,
    };
  }
}
