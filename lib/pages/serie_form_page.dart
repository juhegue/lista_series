import 'package:flutter/material.dart';
import 'package:lista_series/widgets/incrementa_decrementa.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:pasteboard/pasteboard.dart';

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
                      _imagen = await Pasteboard.image;
                      setState(() {});
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
