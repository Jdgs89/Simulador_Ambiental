import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/medicion.dart';
import '../services/simulacion_service.dart';
import '../widgets/slider_variable.dart';

/// Pantalla del simulador: el usuario ajusta la temperatura y obtiene
/// una estimación de CO₂ basada en los datos reales del sensor.
///
/// La humedad se muestra como contexto (la del registro base) pero NO
/// entra a la fórmula, porque en los datos reales está casi
/// perfectamente colineal con la temperatura (r = -0.979).
class SimuladorScreen extends StatefulWidget {
  const SimuladorScreen({super.key});

  @override
  State<SimuladorScreen> createState() => _SimuladorScreenState();
}

class _SimuladorScreenState extends State<SimuladorScreen> {
  final _servicio = SimulacionService();

  Medicion? _base;
  bool _cargando = true;
  String? _error;

  double _temperatura = 25.0;
  double? _co2Estimado;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final ultima = await DatabaseHelper.instance.obtenerUltimaMedicion();
      if (!mounted) return;
      setState(() {
        _base = ultima;
        if (ultima != null) _temperatura = ultima.temperature;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo leer la base de datos.\n$e';
        _cargando = false;
      });
    }
  }

  void _simular() {
    setState(() => _co2Estimado = _servicio.estimarCo2(_temperatura));
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_error!, textAlign: TextAlign.center),
        ),
      );
    }
    if (_base == null) {
      return const Center(child: Text('No hay datos base para simular.'));
    }

    final base = _base!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Estima el CO₂ a partir de las condiciones ambientales, '
          'usando un modelo de regresión calculado con las 568 '
          'mediciones reales del sensor (R² ≈ 0.46).',
          style: TextStyle(color: Colors.grey[700]),
        ),
        const SizedBox(height: 16),

        // --- Entrada ---
        Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Condición a simular',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SliderVariable(
                  etiqueta: 'Temperatura',
                  unidad: '°C',
                  valor: _temperatura,
                  min: SimulacionService.tempMinEntrada,
                  max: SimulacionService.tempMaxEntrada,
                  onChanged: (v) => setState(() {
                    _temperatura = v;
                    _co2Estimado = null; // invalida el resultado anterior
                  }),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.water_drop, size: 16, color: Colors.blue[300]),
                    const SizedBox(width: 6),
                    Text(
                      'Humedad de referencia: '
                      '${base.humidity.toStringAsFixed(1)} % (contexto)',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        FilledButton.icon(
          onPressed: _simular,
          icon: const Icon(Icons.play_arrow),
          label: const Text('Simular'),
        ),
        const SizedBox(height: 16),

        // --- Resultado ---
        if (_co2Estimado != null) _buildResultado(base),
      ],
    );
  }

  Widget _buildResultado(Medicion base) {
    final estimado = _co2Estimado!;
    final diferencia = estimado - base.co2;
    final porcentaje =
        base.co2 != 0 ? (diferencia / base.co2) * 100 : 0.0;
    final sube = diferencia >= 0;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Resultado',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(height: 20),
            _bloque('CONDICIONES BASE', [
              'Temperatura: ${base.temperature.toStringAsFixed(1)} °C',
              'Humedad: ${base.humidity.toStringAsFixed(1)} %',
              'CO₂: ${base.co2.toStringAsFixed(0)} ppm',
            ]),
            const SizedBox(height: 12),
            _bloque('SIMULACIÓN', [
              'Temperatura: ${_temperatura.toStringAsFixed(1)} °C',
              'Humedad: ${base.humidity.toStringAsFixed(1)} % (sin cambio)',
              'CO₂ estimado: ${estimado.toStringAsFixed(0)} ppm',
            ]),
            const Divider(height: 20),
            Row(
              children: [
                Icon(
                  sube ? Icons.trending_up : Icons.trending_down,
                  color: sube ? Colors.red[400] : Colors.green[600],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${sube ? '+' : ''}${diferencia.toStringAsFixed(0)} ppm '
                    '(${sube ? '+' : ''}${porcentaje.toStringAsFixed(1)} %)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: sube ? Colors.red[400] : Colors.green[600],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _bloque(String titulo, List<String> lineas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
                letterSpacing: 0.5)),
        const SizedBox(height: 4),
        for (final l in lineas) Text(l),
      ],
    );
  }
}
