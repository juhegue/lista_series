import 'package:flutter/material.dart';
import 'package:lista_series/widgets/incrementa_decrementa.dart';
import 'package:lista_series/services/database_service.dart';
import 'package:lista_series/models/serie.dart';
import 'package:lista_series/constants.dart'
    show kImageBase64Galeria, kImageBase64Clipboar;
import 'package:image_picker/image_picker.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

var _kImageBase64 = (defaultTargetPlatform == TargetPlatform.android)
    ? kImageBase64Galeria
    : kImageBase64Clipboar;

class SerieFormPage extends StatefulWidget {
  const SerieFormPage({Key? key, this.serie}) : super(key: key);
  final Serie? serie;

  @override
  State<SerieFormPage> createState() => _SerieFormPageState();
}

class _SerieFormPageState extends State<SerieFormPage> {
  late final DatabaseService _databaseService;
  final TextEditingController _nombreController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  int _temporada = 1;
  int _capitulo = 1;
  Uint8List? _imagen;
  bool _vista = false;
  bool _aparcada = false;
  int? serieId;

  void getSerieId() {
    serieId = (widget.serie == null) ? null : widget.serie?.id;
  }

  @override
  void initState() {
    super.initState();

    _databaseService = DatabaseService();

    if (widget.serie != null) {
      _nombreController.text = widget.serie!.nombre;
      _temporada = widget.serie!.temporada;
      _capitulo = widget.serie!.capitulo;
      _imagen = widget.serie!.imagen;
      _vista = widget.serie!.vista!;
      _aparcada = widget.serie!.aparcada!;
    }
  }

  @override
  void dispose() {
    _databaseService.close();
    super.dispose();
  }

  void _saveSerie() {
    Serie serie = Serie(
      id: serieId,
      nombre: _nombreController.text,
      temporada: _temporada,
      capitulo: _capitulo,
      vista: _vista,
      aparcada: _aparcada,
      imagen: _imagen,
    );
    serie.saveSerie(_databaseService);
    Navigator.pop(context);
  }

  void _deleteSerie() {
    widget.serie!.deleteSerie(_databaseService);
    Navigator.pop(context);
  }

  void _getDataFile(file) async {
    var data = await file.readAsBytes();
    setState(() {
      _imagen = data;
    });
  }

  Future _getImageSource(ImageSource media) async {
    try {
      var img = await picker.pickImage(source: media);
      var file = File(img!.path);
      _getDataFile(file);
    } on Exception catch (_) {}
  }

  Future _getImageSourceClipboard() async {
    _imagen = await Pasteboard.image;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    getSerieId();

    return Scaffold(
        appBar: AppBar(
          title: const Text('Añadir nueva serie'),
          backgroundColor: Colors.teal,
          centerTitle: true,
        ),
        body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Introduzca el nombre de la serie',
                    ),
                    onChanged: (text) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 10.0),
                  IncrementaDecrementa(
                    titulo: 'Temporada',
                    valor: _temporada.toDouble(),
                    onIncrementa: () {
                      setState(() {
                        _temporada++;
                      });
                    },
                    onDecrementa: () {
                      setState(() {
                        (_temporada > 1) ? _temporada-- : _temporada;
                      });
                    },
                  ),
                  const SizedBox(height: 4.0),
                  IncrementaDecrementa(
                    titulo: 'Capítulo',
                    valor: _capitulo.toDouble(),
                    onIncrementa: () {
                      setState(() {
                        _capitulo++;
                      });
                    },
                    onDecrementa: () {
                      setState(() {
                        (_capitulo > 1) ? _capitulo-- : _capitulo;
                      });
                    },
                  ),
                  const SizedBox(height: 4.0),
                  const Text(
                    'Esta vista',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Checkbox(
                    value: _vista,
                    onChanged: (bool? value) {
                      setState(() {
                        _vista = value!;
                        if (_vista) _aparcada = false;
                      });
                    },
                  ),
                  const SizedBox(height: 4.0),
                  const Text(
                    'Esta aparcada',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Checkbox(
                    value: _aparcada,
                    onChanged: (bool? value) {
                      setState(() {
                        _aparcada = value!;
                        if (_aparcada) _vista = false;
                      });
                    },
                  ),
                  const SizedBox(height: 4.0),
                  const Text(
                    'Imagen',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  MaterialButton(
                    onPressed: () async {
                      if (defaultTargetPlatform == TargetPlatform.android) {
                        _getImageSource(ImageSource.gallery);
                      } else {
                        _getImageSourceClipboard();
                      }
                    },
                    child: SizedBox(
                        width: 200.0,
                        height: 200.0,
                        child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: (_imagen != null)
                                ? Image.memory(_imagen!)
                                : Image.memory(base64Decode(_kImageBase64)))),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: 45.0,
                        width: 150.0,
                        child: ElevatedButton(
                          onPressed: (_nombreController.text != '')
                              ? () => _saveSerie()
                              : null,
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.green),
                          ),
                          child: const Text(
                            'Grabar',
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 45.0,
                        width: 150.0,
                        child: ElevatedButton(
                          onPressed:
                              (serieId != null) ? () => _deleteSerie() : null,
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.red),
                          ),
                          child: const Text(
                            'Eliminar',
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ])));
  }
}
