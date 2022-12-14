import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:lista_series/services/database_service.dart';

class Serie {
  final int? id;
  final DateTime? fechaCreacion;
  final DateTime? fechaModificacion;
  final String nombre;
  final int temporada;
  final int capitulo;
  final int valoracion;
  final bool? vista;
  final bool? aplazada;
  final bool? descartada;
  final Uint8List? imagen;

  const Serie({
    this.id,
    this.fechaCreacion,
    this.fechaModificacion,
    required this.nombre,
    required this.temporada,
    required this.capitulo,
    required this.valoracion,
    this.vista,
    this.aplazada,
    this.descartada,
    this.imagen,
  });

  Serie.loading()
      : this(
          nombre: '???',
          temporada: 0,
          capitulo: 0,
          valoracion: 0,
        );

  bool get isLoading => nombre == '???';

  Map<String, dynamic> toMap() {
    var ahora = DateTime.now();
    var fecha = fechaCreacion ?? ahora;
    var miliCrea = fecha.millisecondsSinceEpoch;
    var miliModi = ahora.millisecondsSinceEpoch;

    return {
      'id': id,
      'fecha_creacion': miliCrea,
      'fecha_modificacion': miliModi,
      'nombre': nombre,
      'temporada': temporada,
      'capitulo': capitulo,
      'valoracion': valoracion,
      'vista': (vista ?? false) ? 1 : 0,
      'aplazada': (aplazada ?? false) ? 1 : 0,
      'descartada': (descartada ?? false) ? 1 : 0,
      'imagen': (imagen == null) ? null : base64.encode(imagen!),
    };
  }

  @override
  String toString() {
    return 'Serie [$id] $fechaModificacion $nombre T:$temporada C:$capitulo $valoracion $vista $aplazada $descartada}';
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
    fechaModificacion:
        DateTime.fromMillisecondsSinceEpoch(map['fecha_modificacion']),
    nombre: map['nombre'],
    temporada: map['temporada'],
    capitulo: map['capitulo'],
    valoracion: map['valoracion'],
    vista: (map['vista'] == 1) ? true : false,
    aplazada: (map['aplazada'] == 1) ? true : false,
    descartada: (map['descartada'] == 1) ? true : false,
    imagen: (map['imagen'] == null) ? null : base64.decode(map['imagen']),
  );
}

Future countSeries(DatabaseService dbs, int limit, int offset, List filtro,
    [List? orden]) async {
  final db = await dbs.database;
  final int aplazada = (filtro[0] == false && filtro[1] == true) ? 1 : 0;
  final int vista = (filtro[0] == true && filtro[1] == false) ? 1 : 0;
  final int descartada = ((filtro[0] == true && filtro[1] == true)) ? 1 : 0;
  late final int? count;
  late final List<Map<String, dynamic>> maps;

  var columna = (orden != null) ? orden[0] : null;
  var tipo = (orden != null) ? orden[1] : null;

  await db.transaction(
    (txn) async {
      count = (filtro[0] == null && filtro[1] == null)
          ? Sqflite.firstIntValue(
              await txn.rawQuery('SELECT COUNT(*) FROM serie'))
          : Sqflite.firstIntValue(await txn.rawQuery(
              'SELECT COUNT(*) FROM serie WHERE vista=$vista AND aplazada=$aplazada AND descartada=$descartada'));

      maps = (filtro[0] == null && filtro[1] == null)
          ? (orden == null)
              ? await txn.rawQuery(
                  'SELECT * FROM serie ORDER BY nombre COLLATE NOCASE ASC LIMIT $limit OFFSET $offset')
              : await txn.rawQuery(
                  'SELECT * FROM serie ORDER BY $columna COLLATE NOCASE $tipo, nombre COLLATE NOCASE $tipo LIMIT $limit OFFSET $offset')
          : (orden == null)
              ? await txn.rawQuery(
                  'SELECT * FROM serie WHERE vista=$vista AND aplazada=$aplazada AND descartada=$descartada ORDER BY nombre COLLATE NOCASE ASC LIMIT $limit OFFSET $offset')
              : await txn.rawQuery(
                  'SELECT * FROM serie WHERE vista=$vista AND aplazada=$aplazada AND descartada=$descartada ORDER BY $columna COLLATE NOCASE $tipo, nombre COLLATE NOCASE $tipo LIMIT $limit OFFSET $offset');
    },
  );

  List<Serie> list = List.generate(
    maps.length,
    (i) {
      return _mapToSerie(maps[i]);
    },
  );

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
    var serie = todas[1].elementAt(rng.nextInt(todas[0]));
    Serie s = Serie(
      nombre: "${i.toString().padLeft(3, '0')} $serie.nombre",
      temporada: serie.temporada,
      capitulo: serie.capitulo,
      valoracion: serie.valoracion,
      vista: serie.vista,
      aplazada: serie.aplazada,
      descartada: serie.descartada,
      imagen: serie.imagen,
    );
    s.saveSerie(dbs);
  }
}
