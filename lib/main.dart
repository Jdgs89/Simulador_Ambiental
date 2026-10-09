import 'package:flutter/material.dart';

import 'screens/dashboard_screen.dart';
import 'screens/historial_screen.dart';
import 'screens/simulador_screen.dart';

void main() {
  runApp(const SimuladorAmbientalApp());
}

class SimuladorAmbientalApp extends StatelessWidget {
  const SimuladorAmbientalApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Colors.teal;
    return MaterialApp(
      title: 'Simulador Ambiental',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        scaffoldBackgroundColor: const Color(0xFFF5F9F7),
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      home: const HomePage(),
    );
  }
}

/// Contenedor principal con navegación inferior entre
/// Dashboard, Simulador e Historial.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _indice = 0;

  static const _titulos = ['Simulador Ambiental', 'Simulador', 'Historial'];

  @override
  Widget build(BuildContext context) {
    final pantallas = [
      DashboardScreen(
        onIrASimulador: () => setState(() => _indice = 1),
        onIrAHistorial: () => setState(() => _indice = 2),
      ),
      const SimuladorScreen(),
      const HistorialScreen(),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(_titulos[_indice])),
      body: IndexedStack(index: _indice, children: pantallas),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (i) => setState(() => _indice = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.eco), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.tune), label: 'Simulador'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Historial'),
        ],
      ),
    );
  }
}
