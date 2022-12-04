// ignore_for_file: constant_identifier_names

import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:lista_series/services/database_service.dart';
import 'package:lista_series/models/serie.dart';
import 'package:lista_series/pages/serie_form_page.dart';
import 'package:lista_series/widgets/serie_builder.dart';
import 'package:lista_series/util/backu_restore.dart';
import 'package:lista_series/widgets/dialog.dart';

const ORDEN = {
  1: ['nombre', 'ASC'],
  2: ['fecha_creacion', 'ASC'],
  3: ['fecha_modificacion', 'ASC'],
  4: ['valoracion', 'ASC'],
  -1: ['nombre', 'DESC'],
  -2: ['fecha_creacion', 'DESC'],
  -3: ['fecha_modificacion', 'DESC'],
  -4: ['valoracion', 'DESC'],
};

const FILTRO = {
  'viendo': [false, false],
  'aplazadas': [false, true],
  'vistas': [true, false],
  'descartadas': [true, true],
  'todas': [null, null]
};

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  late DatabaseService _databaseService;
  late TabController _controller;
  int _selectedIndex = 0;
  late StreamSubscription _intentDataStreamSubscription;
  List<SharedMediaFile>? _sharedFiles;
  Uint8List? imagenShare;
  int _selectedPopupMenu = 1;

  void addSerieImagen(Uint8List imagenShare) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => SerieFormPage(imagen: imagenShare),
            fullscreenDialog: true,
          ),
        )
        .then(
          (_) => setState(() {}),
        );
  }

  void leeFichero(shared) async {
    try {
      if (shared.isNotEmpty) {
        String path = shared[0].path;
        if (path != '') {
          File f = File(path);
          imagenShare = await f.readAsBytes();
          addSerieImagen(imagenShare!);
        }
      }
    } on Exception catch (_) {}
  }

  void initialization() async {
    await Future.delayed(const Duration(seconds: 1));
    FlutterNativeSplash.remove();
  }

  @override
  void initState() {
    super.initState();
    _databaseService = DatabaseService();

    _controller = TabController(length: 5, vsync: this);
    _controller.addListener(
      () {
        setState(
          () {
            _selectedIndex = _controller.index;
            if (kDebugMode) {
              print('Tab $_selectedIndex');
            }
            // No es necesario, esto sería para forzar a posicionarce en un tab
            //DefaultTabController.of(context)?.animateTo(_selectedIndex);
          },
        );
      },
    );

    if (Platform.isAndroid || Platform.isIOS) {
      // For sharing images coming from outside the app while the app is in the memory
      _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
          .listen((List<SharedMediaFile> value) {
        setState(
          () {
            _sharedFiles = value;
            leeFichero(value);
          },
        );
      }, onError: (err) {});

      // For sharing images coming from outside the app while the app is closed
      ReceiveSharingIntent.getInitialMedia().then(
        (List<SharedMediaFile> value) {
          setState(
            () {
              _sharedFiles = value;
              leeFichero(value);
            },
          );
        },
      );
    }

    initialization();
  }

  @override
  void dispose() {
    _databaseService.close();
    super.dispose();
  }

  void msgResultado(bool resultado, String title, String ok, String ko) async {
    (resultado)
        ? await showMsgDialog(context, title, ok)
        : await showMsgDialog(context, title, ko);
  }

  void msgAviso(String title, String msg) {
    showMsgDialog(context, title, msg);
  }

  Future<void> accionDb(bool close, Function accion, Function result,
      String title, String ok, String ko) async {
    if (await Permission.storage.request().isPermanentlyDenied) {
      await openAppSettings();
    }

    if (close) {
      _databaseService.close();
    }

    bool r = await accion(_databaseService);
    await result(r, title, ok, ko);

    if (close) {
      _databaseService = DatabaseService();
    }

    setState(() {});
  }

  Future<void> sumario() async {
    var viendo = await countSeries(_databaseService, 1, 0, FILTRO['viendo']!);
    var aplazadas =
        await countSeries(_databaseService, 1, 0, FILTRO['aplazadas']!);
    var vistas = await countSeries(_databaseService, 1, 0, FILTRO['vistas']!);
    var descartadas =
        await countSeries(_databaseService, 1, 0, FILTRO['descartadas']!);
    var todas = await countSeries(_databaseService, 1, 0, FILTRO['todas']!);

    String msg =
        'Viendo: ${viendo[0]}\nAplazadas: ${aplazadas[0]}\nVistas: ${vistas[0]}\nDescartadas: ${descartadas[0]}\nTodas: ${todas[0]}';
    msgAviso('Sumario', msg);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Colors.teal),
                accountName: const Text(
                  '©Juhegue',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: const Text(
                  'https://github.com/juhegue/lista_series',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                currentAccountPicture: Image.asset('assets/images/serie.png'),
              ),
              /*                
                const DrawerHeader(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/serie.png'),
                      //fit: BoxFit.fitHeight,
                      //scale:0.5
                    ),
                    color: Colors.teal,
                  ),
                  child: Text('Juhegue'),
                ),*/
              ListTile(
                leading: const Icon(
                  Icons.backup,
                ),
                title: const Text('Realizar backup'),
                onTap: () {
                  accionDb(
                      true,
                      backupDb,
                      msgResultado,
                      'Backup',
                      'Completada con éxito en la carpeta Descargas.',
                      'ERROR.Sin permisos.');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.restore,
                ),
                title: const Text('Restaurar backup'),
                onTap: () {
                  accionDb(true, restoreDb, msgResultado, 'Restaurar Backup',
                      'Completada con éxito.', 'Acción no realizada.');
                  Navigator.pop(context);
                },
              ),
/*                
                ListTile(
                  leading: const Icon(
                    Icons.backup,
                  ),
                  title: const Text('Realizar json backup'),
                  onTap: () {
                    accionDb(
                        false,
                        backupJson,
                        msgResultado,
                        'Backup json',
                        'Completada con éxito en la carpeta Descargas',
                        'ERROR.Sin permisos.');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.restore,
                  ),
                  title: const Text('Restaurar json backup'),
                  onTap: () {
                    accionDb(
                        false,
                        restoreJson,
                        msgResultado,
                        'Restaurar Backup json',
                        'Completada con éxito.',
                        'Acción no realizada.');
                    Navigator.pop(context);
                  },
                ),
*/
              ListTile(
                leading: const Icon(
                  Icons.add_circle_outline,
                ),
                title: const Text('Sumario'),
                onTap: () {
                  sumario();
                },
              ),
              const AboutListTile(
                icon: Icon(
                  Icons.info,
                ),
                applicationIcon: Icon(
                  Icons.local_play,
                ),
                applicationName: 'Lista Serie',
                applicationVersion: '0.0.1',
                applicationLegalese: '© 2022 Juhegue',
                aboutBoxChildren: [
                  Text(
                      'Para los amantes de Kodi que se les olvida la serie vista ;) .'),
                ],
                child: Text('Acerca de...'),
              ),
            ],
          ),
        ),
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
          actions: [
            PopupMenuButton(
              tooltip: 'Ordenación',
              color: Colors.teal.shade300,
              splashRadius: 40,
              itemBuilder: (context) {
                return [
                  popupMenuItem(1, _selectedPopupMenu, 'Nombre'),
                  popupMenuItem(2, _selectedPopupMenu, 'Creación'),
                  popupMenuItem(3, _selectedPopupMenu, 'Modificación'),
                  popupMenuItem(4, _selectedPopupMenu, 'Valoración'),
                ];
              },
              onSelected: (value) {
                setState(() {
                  (_selectedPopupMenu == value)
                      ? _selectedPopupMenu = -value
                      : _selectedPopupMenu = value;
                });
              },
            )
          ],
          bottom: TabBar(
            controller: _controller,
            isScrollable: true,
            unselectedLabelColor: Colors.tealAccent,
            tabs: const [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text('Viendo'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text('Aplazadas'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text('Vistas'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text('Todas'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text('Descartadas'),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _controller,
          children: [
            // Viendo
            Tab(
              child: SerieBuilder(
                databaseService: _databaseService,
                orden: ORDEN[_selectedPopupMenu]!,
                filtro: FILTRO['viendo']!,
                onEdit: (value) {
                  {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (_) => SerieFormPage(serie: value),
                            fullscreenDialog: true,
                          ),
                        )
                        .then((_) => setState(() {}));
                  }
                },
              ),
            ),
            // Aplazadas
            Tab(
              child: SerieBuilder(
                databaseService: _databaseService,
                orden: ORDEN[_selectedPopupMenu]!,
                filtro: FILTRO['aplazadas']!,
                onEdit: (value) {
                  {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (_) => SerieFormPage(serie: value),
                            fullscreenDialog: true,
                          ),
                        )
                        .then((_) => setState(() {}));
                  }
                },
              ),
            ),
            // Vistas
            Tab(
              child: SerieBuilder(
                databaseService: _databaseService,
                orden: ORDEN[_selectedPopupMenu]!,
                filtro: FILTRO['vistas']!,
                onEdit: (value) {
                  {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (_) => SerieFormPage(serie: value),
                            fullscreenDialog: true,
                          ),
                        )
                        .then((_) => setState(() {}));
                  }
                },
              ),
            ),
            // Todas
            Tab(
              child: SerieBuilder(
                databaseService: _databaseService,
                orden: ORDEN[_selectedPopupMenu]!,
                filtro: FILTRO['todas']!,
                onEdit: (value) {
                  {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (_) => SerieFormPage(serie: value),
                            fullscreenDialog: true,
                          ),
                        )
                        .then((_) => setState(() {}));
                  }
                },
              ),
            ),
            // Descartadas
            Tab(
              child: SerieBuilder(
                databaseService: _databaseService,
                orden: ORDEN[_selectedPopupMenu]!,
                filtro: FILTRO['descartadas']!,
                onEdit: (value) {
                  {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (_) => SerieFormPage(serie: value),
                            fullscreenDialog: true,
                          ),
                        )
                        .then((_) => setState(() {}));
                  }
                },
              ),
            )
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context)
                .push(
                  MaterialPageRoute(
                    builder: (_) => const SerieFormPage(),
                    fullscreenDialog: true,
                  ),
                )
                .then((_) => setState(() {}));
          },
          tooltip: 'Añadir Serie',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

PopupMenuItem popupMenuItem(int valor, int selectedPopupMenu, String titulo) {
  return PopupMenuItem(
    value: valor,
    child: Row(children: [
      (selectedPopupMenu == valor)
          ? const Icon(
              Icons.arrow_upward,
              size: 18,
              color: Colors.white,
            )
          : (selectedPopupMenu == -valor)
              ? const Icon(
                  Icons.arrow_downward,
                  size: 18,
                  color: Colors.white,
                )
              : const SizedBox(width: 18),
      Text(
        titulo,
        style: const TextStyle(
          color: Colors.tealAccent,
        ),
      ),
    ]),
  );
}
