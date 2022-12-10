import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter/foundation.dart';
import 'package:window_size/window_size.dart';
import 'package:lista_series/pages/home_page.dart';
import 'package:lista_series/services/database_service.dart';
import 'package:lista_series/models/preferencia.dart';

void main() {
  setupWindow();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  DatabaseService databaseService = DatabaseService();
  Preferencia.get(databaseService).then((result) {
    runApp(MyApp(preferencia: result));
  });
}

const double windowWidth = 480;
const double windowHeight = 854;

void setupWindow() {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    WidgetsFlutterBinding.ensureInitialized();
    setWindowTitle('Lista Series');
    setWindowMinSize(const Size(windowWidth, windowHeight));
    setWindowMaxSize(const Size(windowWidth, windowHeight));
/*    
    getCurrentScreen().then((screen) {
      setWindowFrame(Rect.fromCenter(
        center: screen!.frame.center,
        width: windowWidth,
        height: windowHeight,
      ));
    });
*/
  }
}

class MyApp extends StatelessWidget {
  final Preferencia preferencia;
  const MyApp({super.key, required this.preferencia});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista Series',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: MyHomePage(preferencia: preferencia, title: 'Lista Series'),
    );
  }
}
