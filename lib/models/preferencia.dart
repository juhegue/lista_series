import 'package:sqflite/sqflite.dart';
import 'package:lista_series/services/database_service.dart';

class Preferencia {
  final int tabIndex;
  final int ordenIndex;

  Preferencia({
    required this.tabIndex,
    required this.ordenIndex,
  });

  int id = 1;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tab_index': tabIndex,
      'orden_index': ordenIndex,
    };
  }

  factory Preferencia.fromMap(Map<String, dynamic> map) {
    return Preferencia(
      tabIndex: map['tab_index'],
      ordenIndex: map['orden_index'],
    );
  }

  @override
  String toString() {
    return 'Preferencia: tab $tabIndex orden $ordenIndex';
  }

  Future<void> save(DatabaseService dbs) async {
    Preferencia? preferencia = await get(dbs);
    (preferencia == null) ? _insert(dbs) : _update(dbs);
  }

  Future<void> _insert(DatabaseService dbs) async {
    final db = await dbs.database;

    await db.insert(
      'preferencia',
      toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _update(DatabaseService dbs) async {
    final db = await dbs.database;

    await db.update(
      'preferencia',
      toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> delete(DatabaseService dbs) async {
    final db = await dbs.database;
    await db.delete(
      'preferencia',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<Preferencia?> get(DatabaseService dbs) async {
    final db = await dbs.database;
    final List maps = await db.query(
      'preferencia',
      where: 'id = ?',
      whereArgs: [1],
    );
    return (maps.isEmpty) ? null : Preferencia.fromMap(maps[0]);
  }
}
