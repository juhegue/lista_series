import 'package:flutter/material.dart';

class OutlinedText extends StatelessWidget {
  final String text;
  final Color borderColor;
  final Color foreColor;
  final double fontSize;

  const OutlinedText({
    super.key,
    required this.text,
    required this.borderColor,
    required this.foreColor,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      shadows: [
        Shadow(
          color: borderColor,
          blurRadius: 6,
          offset: const Offset(0, 0),
        )
      ],
      color: foreColor,
      fontSize: fontSize,
     // fontWeight: FontWeight.bold,
    );
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          text,
          style: textStyle.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..color = foreColor
              ..strokeWidth = 1,
            color: null,
          ),
        ),
        Text(text, style: textStyle),
      ],
    );
  }
}
