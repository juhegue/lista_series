import 'dart:typed_data';
import 'dart:convert';
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
      'imagen': (imagen == null) ? null : base64.encode(imagen!),
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

Future<List<Serie>> allSeries(DatabaseService dbs,
    [bool? vista, bool? aplazada]) async {
  final db = await dbs.database;

  final int xvista = (vista == null || !vista) ? 0 : 1;
  final int xaplazada = (aplazada == null || !aplazada) ? 0 : 1;

  final List<Map<String, dynamic>> maps = (vista == null && aplazada == null)
      ? await db.query('serie', orderBy: 'nombre COLLATE NOCASE ASC')
      : await db.query('serie',
          where: 'vista = ? AND aplazada = ?',
          whereArgs: [xvista, xaplazada],
          orderBy: 'nombre COLLATE NOCASE ASC');

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
      imagen:
          (maps[i]['imagen'] == null) ? null : base64.decode(maps[i]['imagen']),
    );
  });
}
