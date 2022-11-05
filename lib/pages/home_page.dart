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

class _MyHomePageState extends State<MyHomePage> {
  late final DatabaseService _databaseService;

  @override
  void initState() {
    super.initState();
    _databaseService = DatabaseService();
  }

  @override
  void dispose() {
    _databaseService.close();
    super.dispose();
  }

  Future<List<Serie>> _getSeries() async {
    return await allSeries(_databaseService);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            centerTitle: true,
            bottom: const TabBar(
              unselectedLabelColor: Colors.tealAccent,
              tabs: [
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
            },
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
        ));
  }

  void saveSerie() {}
}
