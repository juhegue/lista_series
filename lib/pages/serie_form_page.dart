import 'package:flutter/material.dart';
import 'package:lista_series/widgets/incrementa_decrementa.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const _kImageBase64 =
    "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";

class SerieFormPage extends StatefulWidget {
  const SerieFormPage({Key? key}) : super(key: key);

  @override
  State<SerieFormPage> createState() => _SerieFormPageState();
}

class _SerieFormPageState extends State<SerieFormPage> {
  final TextEditingController _nombreController = TextEditingController();
  int _temporada = 1;
  int _capitulo = 1;
  Uint8List? _imagen;
  bool _vista = false;
  bool _aparcada = false;
  TextEditingController mytext = TextEditingController();

  void _getDataHtml(url) async {
    try {
      final response = await http.get(Uri.parse(url));
      _imagen = response.bodyBytes;
    } on Exception catch (_) {
      _imagen = null;
    }
    setState(() {});
  }

  void _getClipboard(mytext) async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    var url = (data!.text == null) ? '' : data.text;
    mytext.text = url;
    _getDataHtml(url);
  }

  @override
  Widget build(BuildContext context) {
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
                  ),
                  const SizedBox(height: 16.0),
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
                  const SizedBox(height: 16.0),
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
                  const SizedBox(height: 16.0),
                  const Text(
                    'Esta vista',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Checkbox(
                    value: _vista,
                    onChanged: (bool? value) {
                      setState(() {
                        _vista = value!;
                      });
                    },
                  ),
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
                      });
                    },
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Imagen',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Visibility(
                      visible: false,
                      child: TextField(
                        controller: mytext,
                      )),
                  MaterialButton(
                    onPressed: () async {
                      _getClipboard(mytext);
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
                ])));
  }
}
