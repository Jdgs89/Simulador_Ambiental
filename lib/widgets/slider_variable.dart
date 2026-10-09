import 'package:flutter/material.dart';

/// Slider etiquetado para ajustar una variable de entrada del simulador.
class SliderVariable extends StatelessWidget {
  final String etiqueta;
  final String unidad;
  final double valor;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const SliderVariable({
    super.key,
    required this.etiqueta,
    required this.valor,
    required this.min,
    required this.max,
    required this.onChanged,
    this.unidad = '',
  });

  @override
  Widget build(BuildContext context) {
    final sufijo = unidad.isEmpty ? '' : ' $unidad';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$etiqueta: ${valor.toStringAsFixed(1)}$sufijo',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        Slider(
          value: valor.clamp(min, max),
          min: min,
          max: max,
          divisions: ((max - min) * 2).round(), // pasos de 0.5
          label: '${valor.toStringAsFixed(1)}$sufijo',
          onChanged: onChanged,
        ),
      ],
    );
  }
}
