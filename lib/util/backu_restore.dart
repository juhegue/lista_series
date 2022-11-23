// ignore_for_file: constant_identifier_names

import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lista_series/services/database_service.dart';

const ENCRYPT_DB = false;

Future<Uint8List> getBytesFile(File file) async {
  final data = await file.readAsBytes();
  return data;
}

Future<String> getStringFile(File file) async {
  final data = await file.readAsString();
  return data;
}

Future<File?> getFileStorage() async {
  FilePickerResult? picker = await FilePicker.platform.pickFiles();
  if (picker != null) {
    final String? path = picker.files.single.path;
    if (path != null) {
      final File file = File(path);
      return file;
    }
  }
  return null;
}

Future<bool> backupJson(DatabaseService databaseRepository) async {
  final String backup =
      await databaseRepository.generateBackup(isEncrypted: ENCRYPT_DB);
  final Directory downloadDirectory = Directory('storage/emulated/0/Download/');
  final DateTime now = DateTime.now();
  final String fecha = DateFormat('yyMMdd').format(now);
  final String nombre = '${fecha}_lista_series.json';
  final String path = join('${downloadDirectory.absolute.path}$nombre');
  final File file = File(path);

  if (await Permission.storage.request().isGranted) {
    file.writeAsString(backup);
    return true;
  } else {
    return false;
  }
}

Future<bool> restoreJson(DatabaseService databaseRepository) async {
  final File? fileBackup = await getFileStorage();

  if (fileBackup != null) {
    try {
      final backup = await getStringFile(fileBackup);
      await databaseRepository.clearAllTables();
      final List json =
          databaseRepository.jsonBackup(backup, isEncrypted: ENCRYPT_DB);
      await databaseRepository.restoreBackup(json);
      return true;
    } on Exception catch (_) {}
  }
  return false;
}

Future<bool> backupDb(DatabaseService databaseRepository) async {
  final Directory downloadDirectory = Directory('storage/emulated/0/Download/');
  final DateTime now = DateTime.now();
  final String fecha = DateFormat('yyMMdd').format(now);
  final String nombre = '${fecha}_lista_series.db';
  final String newPath = join('${downloadDirectory.absolute.path}$nombre');
  final String db = await databaseRepository.databasePath();
  final File file = File(db);

  if (await Permission.storage.request().isGranted) {
    await file.copy(newPath);
    return true;
  } else {
    return false;
  }
}

Future<bool> restoreDb(DatabaseService databaseRepository) async {
  final File? fileBackup = await getFileStorage();
  final String db = await databaseRepository.databasePath();

  if (fileBackup != null) {
    try {
      final Uint8List backup = await getBytesFile(fileBackup);
      final String txt = utf8.decode(backup.sublist(0, 6));
      if (txt != 'SQLite') {
        throw Exception();
      }
      await fileBackup.copy(db);
      return true;
    } on Exception catch (_) {}
  }
  return false;
}
