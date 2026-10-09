import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/medicion.dart';
import '../widgets/tarjeta_medicion.dart';

/// Pantalla de historial: lista de todas las mediciones guardadas.
class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  List<Medicion> _mediciones = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final datos = await DatabaseHelper.instance.obtenerMediciones();
      if (!mounted) return;
      setState(() {
        _mediciones = datos;
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
    if (_mediciones.isEmpty) {
      return const Center(child: Text('No hay mediciones disponibles.'));
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _cargando = true);
        await _cargar();
      },
      child: ListView.builder(
        itemCount: _mediciones.length,
        itemBuilder: (context, i) => TarjetaMedicion(medicion: _mediciones[i]),
      ),
    );
  }
}
