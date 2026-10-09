import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/medicion.dart';

/// Helper singleton para la base de datos SQLite local.
///
/// La base real se distribuye como asset (`assets/data/air_quality.db`);
/// en el primer arranque se copia al directorio de bases de datos de la
/// app y desde ahí se abre en modo solo lectura. Nunca se recrea ni se
/// insertan datos desde Dart.
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const String _assetPath = 'assets/data/air_quality.db';
  static const String _dbName = 'air_quality.db';
  static const String tablaMediciones = 'mediciones';

  Database? _db;

  Future<Database> get database async {
    _db ??= await _openDatabase();
    return _db!;
  }

  Future<Database> _openDatabase() async {
    final dbDir = await getDatabasesPath();
    final path = p.join(dbDir, _dbName);

    if (!await File(path).exists()) {
      final data = await rootBundle.load(_assetPath);
      final bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes, flush: true);
    }

    return openDatabase(path, readOnly: true);
  }

  /// Última medición registrada (la más reciente por timestamp).
  Future<Medicion?> obtenerUltimaMedicion() async {
    final db = await database;
    final rows = await db.query(
      tablaMediciones,
      orderBy: 'timestamp DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Medicion.fromMap(rows.first);
  }

  /// Todas las mediciones, de la más reciente a la más antigua.
  Future<List<Medicion>> obtenerMediciones() async {
    final db = await database;
    final rows = await db.query(tablaMediciones, orderBy: 'timestamp DESC');
    return rows.map(Medicion.fromMap).toList();
  }

  /// Las últimas [limite] mediciones en orden cronológico (para gráficas).
  Future<List<Medicion>> obtenerUltimas(int limite) async {
    final db = await database;
    final rows = await db.query(
      tablaMediciones,
      orderBy: 'timestamp DESC',
      limit: limite,
    );
    return rows.map(Medicion.fromMap).toList().reversed.toList();
  }

  Future<void> cerrar() async {
    await _db?.close();
    _db = null;
  }
}
