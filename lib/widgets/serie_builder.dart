import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lista_series/models/serie.dart';
import 'package:lista_series/widgets/outlined_text.dart';
import 'package:lista_series/widgets/dialog.dart';

class SerieBuilder extends StatelessWidget {
  const SerieBuilder({
    Key? key,
    required this.future,
    required this.onEdit,
  }) : super(key: key);
  final Future<List<Serie>> future;
  final Function(Serie) onEdit;

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
    return FutureBuilder<List<Serie>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final serie = snapshot.data![index];
              return _buildSerieCard(serie, context);
            },
          ),
        );
      },
    );
  }

  Widget _buildSerieCard(Serie serie, BuildContext context) {
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
                      Text(
                          'Temporada: ${serie.temporada}\nCapítulo: ${serie.capitulo}\n${DateFormat("dd/MM/yyyy").format(serie.fechaCreacion!)}'),
                    ],
                  ),
                ],
              ),
            ),
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
