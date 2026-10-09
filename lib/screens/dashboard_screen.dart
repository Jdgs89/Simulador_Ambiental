import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../db/database_helper.dart';
import '../models/medicion.dart';
import '../widgets/grafica_serie.dart';

/// Pantalla principal: última medición real del sensor y accesos
/// al simulador y al historial.
class DashboardScreen extends StatefulWidget {
  final VoidCallback? onIrASimulador;
  final VoidCallback? onIrAHistorial;

  const DashboardScreen({super.key, this.onIrASimulador, this.onIrAHistorial});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static final DateFormat _formato = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _formatoHora = DateFormat('HH:mm');

  Medicion? _ultima;
  List<Medicion> _serie = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final db = DatabaseHelper.instance;
      final ultima = await db.obtenerUltimaMedicion();
      final serie = await db.obtenerUltimas(60);
      if (!mounted) return;
      setState(() {
        _ultima = ultima;
        _serie = serie;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo abrir la base de datos.\n$e';
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody(context);
  }

  Widget _buildBody(BuildContext context) {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }
    if (_ultima == null) {
      return const Center(child: Text('No hay mediciones disponibles.'));
    }

    final m = _ultima!;
    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _cargando = true);
        await _cargar();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Monitoreo con datos reales de un sensor ambiental '
            '(SEN66, sala 601).',
            style: TextStyle(color: Colors.grey[700]),
          ),
          const SizedBox(height: 4),
          Text(
            'Última medición: ${_formato.format(m.timestamp)}',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.6,
            children: [
              _tarjetaVariable(
                icono: Icons.thermostat,
                nombre: 'Temperatura',
                valor: m.temperature.toStringAsFixed(1),
                unidad: '°C',
                color: Colors.orange,
              ),
              _tarjetaVariable(
                icono: Icons.water_drop,
                nombre: 'Humedad',
                valor: m.humidity.toStringAsFixed(1),
                unidad: '%',
                color: Colors.blue,
              ),
              _tarjetaVariable(
                icono: Icons.co2,
                nombre: 'CO₂',
                valor: m.co2.toStringAsFixed(0),
                unidad: 'ppm',
                color: Colors.teal,
              ),
              _tarjetaVariable(
                icono: Icons.blur_on,
                nombre: 'PM2.5',
                valor: m.pm25.toStringAsFixed(1),
                unidad: 'µg/m³',
                color: Colors.deepPurple,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: GraficaSerie(
                titulo: 'CO₂ — últimas ${_serie.length} mediciones',
                unidad: 'ppm',
                color: Colors.teal,
                valores: _serie.map((e) => e.co2).toList(),
                etiquetasX:
                    _serie.map((e) => _formatoHora.format(e.timestamp)).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: widget.onIrASimulador,
            icon: const Icon(Icons.tune),
            label: const Text('Ir al simulador'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: widget.onIrAHistorial,
            icon: const Icon(Icons.history),
            label: const Text('Ver historial'),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaVariable({
    required IconData icono,
    required String nombre,
    required String valor,
    required String unidad,
    required Color color,
  }) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icono, size: 18, color: color),
                const SizedBox(width: 6),
                Text(nombre, style: TextStyle(color: Colors.grey[700])),
              ],
            ),
            const Spacer(),
            Text(
              '$valor $unidad',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
