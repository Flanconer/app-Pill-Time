import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Future<Database> getDatabase() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'pilltime_local.db'),
      onCreate: (db, version) async {
        // 1. Tabla de Inventario
        await db.execute('CREATE TABLE medications(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, presentation TEXT, quantity TEXT, unit TEXT)');
        // 2. Tabla de Alarmas (Por tomar)
        await db.execute('CREATE TABLE alarms(id INTEGER PRIMARY KEY AUTOINCREMENT, med_name TEXT, interval TEXT, start_date TEXT, end_date TEXT)');
        // 3. Tabla de Historial (Tomados)
        await db.execute('CREATE TABLE history(id INTEGER PRIMARY KEY AUTOINCREMENT, med_name TEXT, time_taken TEXT)');
      },
      version: 1,
    );
  }

  // --- MEDICAMENTOS (Inventario) ---
  static Future<int> insertMedication(Map<String, dynamic> data) async {
    final db = await getDatabase();
    return await db.insert('medications', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  static Future<List<Map<String, dynamic>>> getMedications() async {
    final db = await getDatabase();
    return await db.query('medications');
  }
  static Future<void> deleteMedication(int id) async {
    final db = await getDatabase();
    await db.delete('medications', where: 'id = ?', whereArgs: [id]);
  }

  // --- ALARMAS (Por tomar) ---
  static Future<int> insertAlarm(Map<String, dynamic> data) async {
    final db = await getDatabase();
    return await db.insert('alarms', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  static Future<List<Map<String, dynamic>>> getAlarms() async {
    final db = await getDatabase();
    return await db.query('alarms');
  }

  // --- HISTORIAL (Tomados) ---
  static Future<int> insertHistory(Map<String, dynamic> data) async {
    final db = await getDatabase();
    return await db.insert('history', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  static Future<List<Map<String, dynamic>>> getHistory() async {
    final db = await getDatabase();
    // Ordenamos por ID descendente para que los más recientes salgan hasta arriba
    return await db.query('history', orderBy: 'id DESC');
  }
}