import 'package:flutter/material.dart';

class IncrementaDecrementa extends StatelessWidget {
  const IncrementaDecrementa({
    Key? key,
    required this.titulo,
    required this.valor,
    required this.onIncrementa,
    required this.onDecrementa,
  }) : super(key: key);
  final String titulo;
  final double valor;
  final Function() onIncrementa;
  final Function() onDecrementa;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        //const SizedBox(height: 4.0),
        Row(
          children: [
            Expanded(
                child: Row(children: [
              Expanded(
                  child: SizedBox(
                //height: 40.0,
                //width: 40.0,  -> no es necesario al tener Expanded
                child: TextButton(
                  child: const Icon(Icons.remove),
                  onPressed: () => onDecrementa(),
                ),
              )),
              Expanded(
                child: SizedBox(
                  //height: 40.0,
                  //width: 40.0,
                  child: TextButton(
                    child: const Icon(Icons.add),
                    onPressed: () => onIncrementa(),
                  ),
                ),
              )
            ])),
            const SizedBox(width: 12.0),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(
                valor.toInt().toString(),
                style: const TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 12.0),
          ],
        ),
      ],
    );
  }
}
