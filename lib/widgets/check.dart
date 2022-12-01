import 'package:flutter/material.dart';

class Check extends StatelessWidget {
  const Check({
    Key? key,
    required this.titulo,
    required this.valor,
    required this.onChanged,
  }) : super(key: key);
  final String titulo;
  final bool valor;
  final Function(bool?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
          child: Text(
        titulo,
        style: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w500,
        ),
      )),
      Checkbox(
        value: valor,
        onChanged: onChanged,
      ),
      const SizedBox(width: 6.0),
    ]);
  }
}
