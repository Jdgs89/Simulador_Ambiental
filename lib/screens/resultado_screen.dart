import 'package:flutter/material.dart';

/// Pantalla de resultado de una simulación.
class ResultadoScreen extends StatelessWidget {
  const ResultadoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resultado')),
      body: const Center(child: Text('Resultado')),
    );
  }
}
