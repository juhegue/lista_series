import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lista_series/models/serie.dart';
import 'package:lista_series/widgets/outlined_text.dart';
import 'package:lista_series/widgets/dialog.dart';
import 'package:lista_series/services/database_service.dart';
import 'package:lista_series/widgets/imagen.dart';

const int seriesPerPage = 100;

class SerieBuilder extends StatelessWidget {
  final DatabaseService databaseService;
  final List filtro;
  final List orden;
  final Function(Serie) onEdit;
  const SerieBuilder({
    Key? key,
    required this.databaseService,
    required this.filtro,
    required this.orden,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final databaseService = DatabaseService();

    //rellenoDemo(databaseService, 1000);

    return ChangeNotifierProvider<Catalog>(
      create: (context) =>
          Catalog(databaseService: databaseService, filtro: filtro),
      child: _SerieBuilder(onEdit: onEdit, orden: orden),
    );
  }
}

class _SerieBuilder extends StatelessWidget {
  final Function(Serie) onEdit;
  final List orden;
  const _SerieBuilder({
    Key? key,
    required this.onEdit,
    required this.orden,
  }) : super(key: key);

  static List? ordenAnterior;

  @override
  Widget build(BuildContext context) {
    bool cacheIndex = false; // para refrescar el indice actual al editar
    bool cacheInit = false; // para iniciar la cache al cambiar el orden

    if (ordenAnterior != null && ordenAnterior != orden) cacheInit = true;
    ordenAnterior = orden;

    return Selector<Catalog, int?>(
      selector: (context, catalog) => catalog.itemCount,
      builder: (context, itemCount, child) => ListView.builder(
        itemCount: itemCount,
        padding: const EdgeInsets.symmetric(vertical: 18),
        itemBuilder: (context, index) {
          var catalog = Provider.of<Catalog>(context);
          var serie = catalog.getByIndex(index, orden, cacheIndex, cacheInit);
          cacheIndex = true;

          if (serie.isLoading) {
            return const LoadingSerieCard();
          }

          return SerieCard(serie: serie, onEdit: onEdit);
        },
      ),
    );
  }
}

class Catalog extends ChangeNotifier {
  final DatabaseService databaseService;
  final List filtro;
  Catalog({
    required this.databaseService,
    required this.filtro,
  });
  static const maxCacheDistance = seriesPerPage * 3;

  final Map<int, SeriePage> _pages = {};

  final Set<int> _pagesBeingFetched = {};

  int? itemCount;

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Serie getByIndex(int index, List orden, bool cacheIndex, bool cacheInit) {
    int startingIndex = (index ~/ seriesPerPage) * seriesPerPage;

    if (cacheInit) {
      _pruneCache(startingIndex);
      startingIndex = 0;
    }

    if (_pages.containsKey(startingIndex) && cacheIndex) {
      Serie serie = _pages[startingIndex]!.series[index - startingIndex];
      return serie;
    }

    _fetchPage(startingIndex, filtro, orden);

    return Serie.loading();
  }

  Future<void> _fetchPage(int startingIndex, List filtro, List orden) async {
    if (_pagesBeingFetched.contains(startingIndex)) {
      return;
    }

    _pagesBeingFetched.add(startingIndex);
    final page = await fetchPage(databaseService, startingIndex, filtro, orden);
    _pagesBeingFetched.remove(startingIndex);

    if (!page.hasNext) {
      itemCount = startingIndex + page.series.length;
    }

    _pages[startingIndex] = page;
    _pruneCache(startingIndex);

    if (!_isDisposed) {
      notifyListeners();
    }
  }

  void _pruneCache(int currentStartingIndex) {
    final keysToRemove = <int>{};
    for (final key in _pages.keys) {
      if ((key - currentStartingIndex).abs() > maxCacheDistance) {
        keysToRemove.add(key);
      }
    }
    for (final key in keysToRemove) {
      _pages.remove(key);
    }
  }
}

class SeriePage {
  final List<Serie> series;
  final int startingIndex;
  final bool hasNext;
  const SeriePage({
    required this.series,
    required this.startingIndex,
    required this.hasNext,
  });
}

Future<SeriePage> fetchPage(DatabaseService databaseService, int startingIndex,
    List filtro, List orden) async {
  final resul = await countSeries(
      databaseService, seriesPerPage, startingIndex, filtro, orden);
  final catalogLength = resul[0];
  final series = resul[1];

  if (kDebugMode) {
    print('fetchPage: $startingIndex $catalogLength');
  }
  if ((startingIndex > catalogLength) || (catalogLength == 0)) {
    if (kDebugMode) {
      print('final');
    }
    return SeriePage(
      series: [Serie.loading()],
      startingIndex: startingIndex,
      hasNext: false,
    );
  }

  return SeriePage(
    series: series,
    startingIndex: startingIndex,
    hasNext: startingIndex + seriesPerPage < catalogLength,
  );
}

class SerieCard extends StatelessWidget {
  final Serie serie;
  final Function onEdit;
  const SerieCard({
    required this.serie,
    required this.onEdit,
    super.key,
  });

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Error al lanzar $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              height: 100.0,
              width: 100.0,
              decoration: BoxDecoration(
                shape: (serie.imagen == null)
                    ? BoxShape.circle
                    : BoxShape.rectangle,
                color: (serie.imagen == null) ? Colors.grey[200] : Colors.white,
              ),
              alignment: Alignment.center,
              child: GestureDetector(
                  onTap: () {
                    final Uri url = Uri.parse(
                        'https://www.google.com/search?q=serie+${serie.nombre}');
                    try {
                      _launchInBrowser(url);
                    } on Exception catch (e) {
                      showMsgDialog(context, 'ERROR', e.toString());
                    }
                  },
                  child: (serie.imagen == null)
                      ? const Icon(Icons.movie, size: 60.0)
                      : Image.memory(serie.imagen!)),
            ),
            const SizedBox(width: 20.0),
            Expanded(
                child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        Imagen(titulo: serie.nombre, imagen: serie.imagen!),
                    fullscreenDialog: true,
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  (serie.vista!)
                      ? OutlinedText(
                          text: serie.nombre,
                          borderColor: Colors.green,
                          foreColor: Colors.black87,
                          fontSize: 18.0)
                      : (serie.aplazada!)
                          ? OutlinedText(
                              text: serie.nombre,
                              borderColor: Colors.blueGrey,
                              foreColor: Colors.black87,
                              fontSize: 18.0)
                          : (serie.descartada!)
                              ? OutlinedText(
                                  text: serie.nombre,
                                  borderColor: Colors.redAccent,
                                  foreColor: Colors.black87,
                                  fontSize: 18.0)
                              : Text(
                                  serie.nombre,
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.black),
                          children: <TextSpan>[
                            TextSpan(
                                text:
                                    'Temporada: ${serie.temporada}\nCapítulo: ${serie.capitulo}\n${DateFormat("dd/MM/yyyy HH:mm").format(serie.fechaModificacion!)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.normal)),
                            TextSpan(
                                text:
                                    '\t\t\t${(serie.valoracion > 0) ? serie.valoracion : ""}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    color: Colors.teal)),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            )),
            const SizedBox(width: 20.0),
            GestureDetector(
              onTap: () => onEdit(serie),
              child: Container(
                height: 40.0,
                width: 40.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                alignment: Alignment.center,
                child: Icon(Icons.edit, color: Colors.orange[800]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoadingSerieCard extends StatelessWidget {
  const LoadingSerieCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              height: 100.0,
              width: 100.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[100],
              ),
              alignment: Alignment.center,
              child: Icon(Icons.movie, color: Colors.grey[300], size: 60.0),
            ),
            const SizedBox(width: 20.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text(
                    '...',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20.0),
            Icon(Icons.autorenew, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}
