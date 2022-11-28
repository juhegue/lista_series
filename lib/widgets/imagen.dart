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
      body: SingleChildScrollView(
        child: Column(children: [
          FittedBox(
            fit: BoxFit.fill,
            child: Image.memory(imagen),
          ),
          const SizedBox(height: 20.0),
          Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: 45.0,
                width: 150.0,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.green),
                  ),
                  child: const Text(
                    'Volver',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              )),
          const SizedBox(height: 20.0),
        ]),
      ),
    );
  }
}
