import 'package:flutter/material.dart';

class ValorarSlider extends StatelessWidget {
  const ValorarSlider({
    Key? key,
    required this.max,
    required this.valor,
    required this.onChanged,
  }) : super(key: key);
  final double max;
  final double valor;
  final Function(double) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(      
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Valoración',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            Expanded(
              child: Slider(
                activeColor: Colors.teal,
                inactiveColor: Colors.tealAccent,
                thumbColor: Colors.black38,
                min: 0.0,
                max: max,
                divisions: max.toInt(),
                value: valor,
                onChanged: onChanged,
              ),
            ),
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
