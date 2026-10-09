import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Gráfica de línea sencilla para una serie temporal de valores.
///
/// Pensada para variables ambientales (CO₂, temperatura, etc.).
/// Muestra ejes simplificados y tooltip al tocar un punto.
class GraficaSerie extends StatelessWidget {
  /// Formato numérico del eje Y con separador de miles: 1020 -> "1,020".
  static final _numeroCompacto = NumberFormat('#,##0');

  final List<double> valores;

  /// Etiquetas del eje X (misma longitud que [valores], p. ej. "HH:mm").
  final List<String> etiquetasX;
  final String titulo;
  final String unidad;
  final Color color;

  const GraficaSerie({
    super.key,
    required this.valores,
    this.etiquetasX = const [],
    this.titulo = '',
    this.unidad = '',
    this.color = Colors.teal,
  });

  @override
  Widget build(BuildContext context) {
    if (valores.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('Sin datos para graficar')),
      );
    }

    final spots = <FlSpot>[
      for (var i = 0; i < valores.length; i++) FlSpot(i.toDouble(), valores[i]),
    ];
    final pasoX = (valores.length / 4).ceil().toDouble();

    // Rango Y con margen y un intervalo "limpio" para que las
    // etiquetas del eje no se solapen.
    var minV = valores.reduce((a, b) => a < b ? a : b);
    var maxV = valores.reduce((a, b) => a > b ? a : b);
    if (minV == maxV) {
      minV -= 1;
      maxV += 1;
    }
    final margen = (maxV - minV) * 0.15;
    final minY = minV - margen;
    final maxY = maxV + margen;
    final pasoY = _pasoLimpio((maxY - minY) / 3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (titulo.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              unidad.isEmpty ? titulo : '$titulo ($unidad)',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              minY: minY,
              maxY: maxY,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: pasoY,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.withValues(alpha: 0.2),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 46,
                    interval: pasoY,
                    getTitlesWidget: (value, meta) => Text(
                      _formatoEje(value),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: etiquetasX.isNotEmpty,
                    reservedSize: 26,
                    interval: pasoX,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= etiquetasX.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          etiquetasX[i],
                          style: const TextStyle(fontSize: 9),
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) => touchedSpots
                      .map(
                        (s) => LineTooltipItem(
                          '${s.y.toStringAsFixed(1)} $unidad',
                          const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      )
                      .toList(),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: color,
                  barWidth: 2.5,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: color.withValues(alpha: 0.15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Devuelve un intervalo "redondo" (1, 2, 2.5, 5, 10...) >= [crudo]
  /// para que las etiquetas del eje Y queden legibles y espaciadas.
  static double _pasoLimpio(double crudo) {
    if (crudo <= 0) return 1;
    final magnitud = crudo.abs().toStringAsExponential(0);
    final base = double.parse(magnitud.split('e')[0]);
    final exp = int.parse(magnitud.split('e')[1]);
    final factor = base <= 1
        ? 1
        : base <= 2
            ? 2
            : base <= 2.5
                ? 2.5
                : base <= 5
                    ? 5
                    : 10;
    return factor * _pow10(exp);
  }

  static double _pow10(int e) {
    var r = 1.0;
    for (var i = 0; i < e.abs(); i++) {
      r = e >= 0 ? r * 10 : r / 10;
    }
    return r;
  }

  /// Formato del eje Y: número completo con separador de miles
  /// (980 -> "980", 1020 -> "1,020"). Se redondea a entero porque el
  /// [pasoY] "limpio" garantiza valores de eje distintos; el antiguo
  /// formato compacto ("1.0K", "1.1K") abreviaba valores diferentes a
  /// la misma etiqueta, produciendo duplicados confusos.
  static String _formatoEje(double v) {
    return _numeroCompacto.format(v.round());
  }
}
