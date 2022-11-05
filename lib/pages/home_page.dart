import 'package:flutter/material.dart';
import 'package:lista_series/models/serie.dart';
import 'package:lista_series/services/database_service.dart';
import 'package:lista_series/pages/serie_form_page.dart';
import 'package:lista_series/widgets/serie_builder.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
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
      });
    });
  }

  @override
  void dispose() {
    _databaseService.close();
    super.dispose();
  }

  Future<List<Serie>> _getSeries() async {
    switch (_selectedIndex) {
      case 0: //Viendo
        {
          return await allSeries(_databaseService, false, false);
        }
      case 1: //Aplazadas
        {
          return await allSeries(_databaseService, false, true);
        }
      case 2: //Vistas
        {
          return await allSeries(_databaseService, true, false);
        }
      default: // Todas
        {
          return await allSeries(_databaseService);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 4,
        child: Scaffold(
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
          body: SerieBuilder(
              future: _getSeries(),
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

          /* TabBarView(
            children: [
              // Viendo
              SerieBuilder(
                  future: _getSeries(),
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
              // Aplazadas
              SerieBuilder(
                future: _getSeries(),
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
              // Vistas
              SerieBuilder(
                future: _getSeries(),
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
              // Todas
              SerieBuilder(
                future: _getSeries(),
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
              )
            ],
          ),*/
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

  void saveSerie() {}
}
