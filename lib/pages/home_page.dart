import 'package:flutter/material.dart';
import 'package:lista_series/pages/serie_form_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'You have pushed the button this many times:',
                ),
                Text(
                  '0',
                  style: Theme.of(context).textTheme.headline4,
                ),
              ],
            ),
          ),
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
