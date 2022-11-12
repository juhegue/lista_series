import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
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

  Serie.loading()
      : this(
          nombre: '???',
          temporada: 0,
          capitulo: 0,
        );

  bool get isLoading => nombre == '???';

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

Serie _mapToSerie(var map) {
  return Serie(
    id: map['id'],
    fechaCreacion: DateTime.fromMillisecondsSinceEpoch(map['fecha_creacion']),
    nombre: map['nombre'],
    temporada: map['temporada'],
    capitulo: map['capitulo'],
    vista: (map['vista'] == 1) ? true : false,
    aplazada: (map['aplazada'] == 1) ? true : false,
    imagen: (map['imagen'] == null) ? null : base64.decode(map['imagen']),
  );
}

Future countSeries(
    DatabaseService dbs, int limit, int offset, List filtro) async {
  final db = await dbs.database;
  final int vista = (filtro[0] == null || !filtro[0]) ? 0 : 1;
  final int aplazada = (filtro[1] == null || !filtro[1]) ? 0 : 1;
  late final int? count;
  late final List<Map<String, dynamic>> maps;

  await db.transaction((txn) async {
    count =
        Sqflite.firstIntValue(await txn.rawQuery('SELECT COUNT(*) FROM serie'));
    maps = (filtro[0] == null && filtro[1] == null)
        ? await txn.rawQuery(
            'SELECT * FROM serie ORDER BY nombre COLLATE NOCASE ASC LIMIT $limit OFFSET $offset')
        : await txn.rawQuery(
            'SELECT * FROM serie WHERE vista=$vista AND aplazada=$aplazada ORDER BY nombre COLLATE NOCASE ASC LIMIT $limit OFFSET $offset');
  });

  var list = List.generate(maps.length, (i) {
    return _mapToSerie(maps[i]);
  });

  return [count ?? 0, list];
}

Future rellenoDemo(DatabaseService dbs, int registros) async {
  List filtro = [null, null];
  var todas = await countSeries(dbs, registros, 0, filtro);
  var rng = Random();

  for (int i = 0; i < registros; i++) {
    if (kDebugMode) {
      print('Relleno $i');
    }
    var serie = todas[1].elementAt(rng.nextInt(9));
    Serie s = Serie(
      nombre: "${i.toString().padLeft(3, '0')} $serie.nombre",
      temporada: serie.temporada,
      capitulo: serie.capitulo,
      vista: serie.vista,
      aplazada: serie.aplazada,
      imagen: serie.imagen,
    );
    s.saveSerie(dbs);
  }
}
