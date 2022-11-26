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
        const SizedBox(height: 8.0),
        Row(
          children: [
            Expanded(
                child: Row(children: [
              SizedBox(
                height: 60.0,
                width: 160.0,
                child: TextButton(
                  child: const Icon(Icons.add),
                  onPressed: () => onIncrementa(),
                ),
              ),
              const SizedBox(width: 60.0),
              SizedBox(
                height: 60.0,
                width: 160.0,
                child: TextButton(
                  child: const Icon(Icons.remove),
                  onPressed: () => onDecrementa(),
                ),
              ),
            ])),
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
