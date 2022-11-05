import 'dart:typed_data';
import 'package:sqflite/sqflite.dart';
import 'package:lista_series/services/database_service.dart';

class Serie {
  final int? id;
  final DateTime? fechaCreacion;
  final String nombre;
  final int temporada;
  final int capitulo;
  final bool? vista;
  final bool? aplazada;
  final Uint8List? imagen;

  const Serie({
    this.id,
    this.fechaCreacion,
    required this.nombre,
    required this.temporada,
    required this.capitulo,
    this.vista,
    this.aplazada,
    this.imagen,
  });

  Map<String, dynamic> toMap() {
    var fecha = fechaCreacion ?? DateTime.now();
    var mili = fecha.millisecondsSinceEpoch;

    return {
      'id': id,
      'fecha_creacion': mili,
      'nombre': nombre,
      'temporada': temporada,
      'capitulo': capitulo,
      'vista': (vista ?? false) ? 1 : 0,
      'aplazada': (aplazada ?? false) ? 1 : 0,
      'imagen': imagen,
    };
  }

  @override
  String toString() {
    return 'Serie [$id] $fechaCreacion $nombre T:$temporada C:$capitulo $vista $aplazada}';
  }

  Future<void> saveSerie(DatabaseService dbs) async {
    (id == null) ? insertSerie(dbs) : updateSerie(dbs);
  }

  Future<void> insertSerie(DatabaseService dbs) async {
    final db = await dbs.database;
    await db.insert(
      'serie',
      toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateSerie(DatabaseService dbs) async {
    final db = await dbs.database;
    await db.update(
      'serie',
      toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteSerie(DatabaseService dbs) async {
    final db = await dbs.database;
    await db.delete(
      'serie',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

Future<List<Serie>> allSeries(DatabaseService dbs, [bool? vistas, bool? aplazadas]) async {
  final db = await dbs.database;
  /* var response = await db.query(TABLE_WORDS, where: '$COL_ENGLISH_WORD = ? OR $COL_GERMAN_WORD = ?', whereArgs: [userSearch, userSearch]);
db.query(table, columns, selection,
        selectionArgs, groupBy, having,
        orderBy + " COLLATE NOCASE ASC");

  */
  final List<Map<String, dynamic>> maps = await db.query('serie', orderBy: 'nombre COLLATE NOCASE ASC');

  return List.generate(maps.length, (i) {
    return Serie(
      id: maps[i]['id'],
      fechaCreacion:
          DateTime.fromMillisecondsSinceEpoch(maps[i]['fecha_creacion']),
      nombre: maps[i]['nombre'],
      temporada: maps[i]['temporada'],
      capitulo: maps[i]['capitulo'],
      vista: (maps[i]['vista'] == 1) ? true : false,
      aplazada: (maps[i]['aplazada'] == 1) ? true : false,
      imagen: maps[i]['imagen'],
    );
  });
}
