// ignore_for_file: constant_identifier_names
import 'dart:io' show Platform;
import 'dart:convert' as convert;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // para windows/linux
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:lista_series/models/serie.dart';

class DatabaseService {
  static final DatabaseService _databaseService = DatabaseService._internal();
  factory DatabaseService() => _databaseService;
  DatabaseService._internal();

  static Database? _database;

  static const SECRET_KEY = '0123456789ABCDEF';
  static const DATABASE_VERSION = 2;

  List<String> tables = ['serie'];

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<String> databasePath() async {
    String databasesPath = await getDatabasesPath();
    return join(databasesPath, 'lista_series.db');
  }

  Future<Database> _initDatabase() async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final path = await databasePath();
    return await openDatabase(
      path,
      onCreate: _onCreate,
      onUpgrade: onUpgrade,
      version: DATABASE_VERSION,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future<void> deleteDB() async {
    String path = await databasePath();
    await deleteDatabase(path);
  }

  Future<void> close() async {
    Database? db = _database;
    (db == null) ? null : await _database!.close();
  }

  Future<void> _onCreate(Database db, int version) => _onCreates[version]!(db);
  final Map<int, Function> _onCreates = {
    1: (Database db) async {
      await db.execute(
        'CREATE TABLE serie(id INTEGER PRIMARY KEY AUTOINCREMENT, fecha_creacion INTEGER, nombre TEXT, temporada INTEGER, capitulo INTEGER,vista INTEGER, aplazada INTEGER, imagen BLOB)',
      );
      if (kDebugMode) {
        print("DATABASE CREATE v1");
      }
    },
    2: (Database db) async {
      await db.execute(
        'CREATE TABLE serie(id INTEGER PRIMARY KEY AUTOINCREMENT, fecha_creacion INTEGER, nombre TEXT, temporada INTEGER, capitulo INTEGER,vista INTEGER, aplazada INTEGER, imagen BLOB)',
      );
      if (kDebugMode) {
        print("DATABASE CREATE v2");
      }
    },
    3: (Database db) async {
      if (kDebugMode) {
        print("DATABASE CREATE v3");
      }
    },
  };

  Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    for (var migration = oldVersion; migration < newVersion; migration++) {
      _onUpgrades["from_version_${migration}_to_version_${migration + 1}"]!(db);
    }
  }

  final Map<String, Function> _onUpgrades = {
    'from_version_1_to_version_2': (Database db) async {
      // Convierte la imagen Uint8List a Base64
      List<Map<String, dynamic>> maps = [];
      maps = await db.query('serie');
      List.generate(maps.length, (i) {
        Serie s = Serie(
            id: maps[i]['id'],
            fechaCreacion:
                DateTime.fromMillisecondsSinceEpoch(maps[i]['fecha_creacion']),
            nombre: maps[i]['nombre'],
            temporada: maps[i]['temporada'],
            capitulo: maps[i]['capitulo'],
            vista: (maps[i]['vista'] == 1) ? true : false,
            aplazada: (maps[i]['aplazada'] == 1) ? true : false,
            imagen: maps[i]['imagen']);

        db.update(
          'serie',
          s.toMap(),
          where: 'id = ?',
          whereArgs: [s.id],
        );
      });

      if (kDebugMode) {
        print('from_version_1_to_version_2');
      }
    },
    'from_version_2_to_version_3': (Database db) async {
      if (kDebugMode) {
        print('from_version_2_to_version_3');
      }
    },
  };

  Future clearAllTables() async {
    try {
      var dbs = await database;
      for (String table in tables) {
        await dbs.delete(table);
        await dbs.rawQuery("DELETE FROM sqlite_sequence where name='$table'");
      }
    } on Exception catch (_) {}
  }

  Future<String> generateBackup({bool isEncrypted = false}) async {
    var dbs = await database;
    List data = [];
    List<Map<String, dynamic>> listMaps = [];

    for (var i = 0; i < tables.length; i++) {
      listMaps = await dbs.query(tables[i]);
      data.add(listMaps);
    }

    List backups = [tables, data];
    String json = convert.jsonEncode(backups);

    if (isEncrypted) {
      var key = encrypt.Key.fromUtf8(SECRET_KEY);
      var iv = encrypt.IV.fromLength(16);
      var encrypter = encrypt.Encrypter(encrypt.AES(key));
      var encrypted = encrypter.encrypt(json, iv: iv);
      return encrypted.base64;
    } else {
      return json;
    }
  }

  Future<void> restoreBackup(String backup, {bool isEncrypted = false}) async {
    var dbs = await database;

    Batch batch = dbs.batch();

    var key = encrypt.Key.fromUtf8(SECRET_KEY);
    var iv = encrypt.IV.fromLength(16);
    var encrypter = encrypt.Encrypter(encrypt.AES(key));

    List json = convert
        .jsonDecode(isEncrypted ? encrypter.decrypt64(backup, iv: iv) : backup);

    for (var i = 0; i < json[0].length; i++) {
      for (var k = 0; k < json[1][i].length; k++) {
        batch.insert(json[0][i], json[1][i][k]);
      }
    }
    // NOTA: no usar Uint8List, convertir a base64!, ya que sqflite no soporta GrowableList
    await batch.commit(continueOnError: false, noResult: true);
  }
}
