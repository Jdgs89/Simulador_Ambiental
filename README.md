# Simulador Ambiental 🌡️💨

**Simulador móvil de condiciones ambientales basado en datos reales de sensores IoT.**

Aplicación Android desarrollada en Flutter/Dart que carga mediciones reales de un sensor ambiental (SEN66), las almacena localmente en SQLite y permite consultarlas y simular escenarios modificando variables ambientales.

Proyecto para la materia *Simuladores de Dispositivos Móviles*.

## 📱 ¿Qué hace la app?

| Pantalla | Contenido |
|---|---|
| **Inicio (Dashboard)** | Tarjetas con la última medición de Temperatura, Humedad, CO₂ y PM2.5, más una gráfica de la evolución del CO₂ |
| **Simulador** | Slider de temperatura (15–35 °C) que estima el CO₂ del escenario usando el modelo estadístico |
| **Resultado** | Comparación del CO₂ estimado frente a los valores reales observados por el sensor |
| **Historial** | Lista de las 568 mediciones almacenadas |

Funciona 100% offline: no usa login, Firebase, APIs ni backend.

## 📊 Los datos

- **Fuente:** dataset público [Air-Quality-Monitoring-Dataset-1](https://github.com/astmarinov/Air-Quality-Monitoring-Dataset-1), datos *Stationary*, grupo 601.
- **Archivo usado:** `sen66_20260401_075451.csv` (~9.4 h de mediciones continuas, 64,863 registros cada ~0.5 s).
- **Procesamiento** (script reproducible `scripts/csv_to_sqlite.py`, solo stdlib de Python):
  - Promedio por minuto → **568 mediciones** (1 por minuto).
  - Limpieza: se descartan CO₂ ≥ 60,000 ppm, temperatura ≤ 0 °C y humedad ≤ 0 %.
  - Resultado: `assets/data/air_quality.db` (tabla `mediciones`, 88 KB), incluido como asset de la app.

## 🧮 Modelo de simulación

Estimación por **regresión lineal simple** (mínimos cuadrados) calculada sobre las 568 mediciones reales:

```
CO₂_estimado (ppm) = -1185.07 + 70.09 · temperatura (°C)      R² ≈ 0.46
```

- **Pendiente (70.09):** por cada °C adicional, el CO₂ estimado sube ~70 ppm.
- **Intercepto (-1185.07):** ajuste de la recta a los datos reales; no tiene interpretación física por sí solo.
- La salida se limita al rango **300–2000 ppm** (aire exterior ~300 ppm; límite prudente en interiores 2000 ppm) para evitar estimaciones absurdas.

**Nota metodológica:** es un modelo estadístico *descriptivo* basado en los datos, no una relación causal. La humedad no entra a la fórmula porque en los datos reales está casi perfectamente colineal con la temperatura (r = −0.979); incluirla haría el modelo inestable sin aportar información adicional.

## 🗂️ Estructura del código

```
lib/
├── main.dart                  # Navegación (NavigationBar: Inicio/Simulador/Historial)
├── db/database_helper.dart    # Copia el asset SQLite y lo abre con sqflite
├── models/medicion.dart       # Modelo de una medición
├── services/simulacion_service.dart  # Fórmula de estimación de CO₂
├── screens/                   # Dashboard, Simulador, Resultado, Historial
└── widgets/                   # Tarjetas, gráfica (fl_chart), slider
scripts/csv_to_sqlite.py       # Conversión reproducible CSV → SQLite
test/                          # Tests del modelo y de la app
```

Dependencias (mínimas): `sqflite`, `path_provider`, `path`, `fl_chart`, `intl`.

## ▶️ Cómo ejecutarlo

Requisitos: Flutter SDK (Dart ≥ 3.13) y un emulador/dispositivo Android (NDK 28.2.13676358).

```bash
flutter pub get
flutter analyze     # → No issues found
flutter test        # → 4 tests pasan
flutter run         # en un emulador o dispositivo Android conectado
```

Para generar el APK:

```bash
flutter build apk --release
```

## ✅ Estado

- Etapa 1 (datos + Dashboard + Historial): probada en emulador Android con datos reales.
- Etapa 2 (simulador con regresión): probada en emulador (clamp inferior verificado: 15 °C → 300 ppm).
- `flutter analyze` sin issues; `flutter test` en verde.
