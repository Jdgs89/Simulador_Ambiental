import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/medicion.dart';

/// Tarjeta que muestra el resumen de una medición ambiental.
class TarjetaMedicion extends StatelessWidget {
  final Medicion medicion;

  const TarjetaMedicion({super.key, required this.medicion});

  static final DateFormat _formato = DateFormat('dd/MM/yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE0F2F1),
          child: Icon(Icons.eco, color: Colors.teal),
        ),
        title: Text(_formato.format(medicion.timestamp)),
        subtitle: Text(
          '🌡 ${medicion.temperature.toStringAsFixed(1)} °C   '
          '💧 ${medicion.humidity.toStringAsFixed(1)} %\n'
          'CO₂ ${medicion.co2.toStringAsFixed(0)} ppm   '
          'PM2.5 ${medicion.pm25.toStringAsFixed(1)} µg/m³',
        ),
        isThreeLine: true,
      ),
    );
  }
}
