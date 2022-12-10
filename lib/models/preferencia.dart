import 'package:sqflite/sqflite.dart';
import 'package:lista_series/services/database_service.dart';

class Preferencia {
  final int? id;
  final int tabIndex;
  final int ordenIndex;

  const Preferencia({
    this.id,
    required this.tabIndex,
    required this.ordenIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tab_index': tabIndex,
      'orden_index': ordenIndex,
    };
  }

  factory Preferencia.fromMap(Map<String, dynamic> map) {
    return Preferencia(
      id: map['id'],
      tabIndex: map['tab_index'],
      ordenIndex: map['orden_index'],
    );
  }

  @override
  String toString() {
    return 'Preferencia [$id] tab $tabIndex orden $ordenIndex';
  }

  Future<void> save(DatabaseService dbs) async {
    Preferencia preferencia = await get(dbs);

    Preferencia p =
        Preferencia(id: 1, tabIndex: tabIndex, ordenIndex: ordenIndex);

    (preferencia.id == 0) ? p._insert(dbs) : p._update(dbs);
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
      whereArgs: [1],
    );
  }

  Future<void> delete(DatabaseService dbs) async {
    final db = await dbs.database;
    await db.delete(
      'preferencia',
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  static Future<Preferencia> get(DatabaseService dbs) async {
    final db = await dbs.database;
    final List maps = await db.query(
      'preferencia',
      where: 'id = ?',
      whereArgs: [1],
    );
    return (maps.isEmpty)
        ? Preferencia.fromMap({'id': 0, 'tab_index': 0, 'orden_index': 1})
        : Preferencia.fromMap(maps[0]);
  }
}
