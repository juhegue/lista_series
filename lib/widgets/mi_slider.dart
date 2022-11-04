import 'package:flutter/material.dart';

class MiSlider extends StatelessWidget {
  const MiSlider({
    Key? key,
    required this.titulo,
    required this.max,
    required this.valor,
    required this.onChanged,
    required this.onIncrementa,
    required this.onDecrementa,
  }) : super(key: key);
  final double max;
  final String titulo;
  final double valor;
  final Function(double) onChanged;
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
              child: Slider(
                min: 0.0,
                max: max,
                divisions: max.toInt(),
                value: valor,
                onChanged: onChanged,
              ),
            ),
            SizedBox(
              height: 30.0,
              width: 40.0,
              child: TextButton(
                child: const Icon(Icons.add),
                onPressed: () => onIncrementa(),
              ),
            ),
            const SizedBox(width: 30.0),
            SizedBox(
              height: 30.0,
              width: 40.0,
              child: TextButton(
                child: const Icon(Icons.remove),
                onPressed: () => onDecrementa(),
              ),
            ),
            const SizedBox(width: 30.0),
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
