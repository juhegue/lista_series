import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lista_series/services/database_service.dart';
import 'package:lista_series/pages/serie_form_page.dart';
import 'package:lista_series/widgets/serie_builder.dart';
import 'package:lista_series/util/backu_restore.dart';
import 'package:lista_series/widgets/dialog.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  late final DatabaseService _databaseService;
  late TabController _controller;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _databaseService = DatabaseService();

    _controller = TabController(length: 4, vsync: this);
    _controller.addListener(() {
      setState(() {
        _selectedIndex = _controller.index;
        if (kDebugMode) {
          print('Tab $_selectedIndex');
        }
        // No es necesario, esto sería para forzar a posicionarce en un tab
        //DefaultTabController.of(context)?.animateTo(_selectedIndex);
      });
    });
  }

  @override
  void dispose() {
    _databaseService.close();
    super.dispose();
  }

  void msgResultado(bool resultado, String title, String ok, String ko) {
    (resultado)
        ? showMsgDialog(context, title, ok)
        : showMsgDialog(context, title, ko);
  }

  Future<void> accionDb(Function accion, Function result, String title,
      String ok, String ko) async {
    if (await Permission.storage.request().isPermanentlyDenied) {
      await openAppSettings();
    }
    bool r = await accion(_databaseService);
    result(r, title, ok, ko);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 4,
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
                    accionDb(restoreDb, msgResultado, 'Restaurar Backup',
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
                    accionDb(restoreJson, msgResultado, 'Restaurar Backup json',
                        'Completada con éxito.', 'Acción no realizada.');
                    Navigator.pop(context);
                  },
                ),
*/
                const AboutListTile(
                  icon: Icon(
                    Icons.info,
                  ),
                  applicationIcon: Icon(
                    Icons.local_play,
                  ),
                  applicationName: 'Lista Serie',
                  applicationVersion: '0.1.beta',
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
                filtro: const [false, false],
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
              )),
              // Aplazadas
              Tab(
                child: SerieBuilder(
                    databaseService: _databaseService,
                    filtro: const [false, true],
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
                    }),
              ),
              // Vistas
              Tab(
                child: SerieBuilder(
                    databaseService: _databaseService,
                    filtro: const [true, false],
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
                    }),
              ),
              // Todas
              Tab(
                child: SerieBuilder(
                    databaseService: _databaseService,
                    filtro: const [null, null],
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
                    }),
              )
            ],
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
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
        ));
  }
}
