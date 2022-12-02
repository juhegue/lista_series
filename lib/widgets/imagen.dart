import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class Imagen extends StatelessWidget {
  final String titulo;
  final Uint8List imagen;
  const Imagen({Key? key, required this.titulo, required this.imagen})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(titulo),
          centerTitle: true,
        ),
        body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
          image: Image.memory(imagen).image,
          fit: BoxFit.cover,
        ))));
  }
}
