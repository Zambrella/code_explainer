import 'package:code_explainer/token.dart';
import 'package:flutter/material.dart';

class CodePainter extends CustomPainter {
  const CodePainter(this.tokens);

  final Iterable<Token> tokens;

  @override
  void paint(Canvas canvas, Size size) {
    const textStyle = TextStyle(
      color: Colors.black,
      fontSize: 30,
      fontFamily: 'mono',
    );
    final textSpan = TextSpan(
      style: textStyle,
      children: tokens.map((e) {
        print(e);
        return TextSpan(
          text: e.toString(),
        );
      }).toList(),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    final xCenter = (size.width - textPainter.width) / 2;
    final yCenter = (size.height - textPainter.height) / 2;
    final offset = Offset(xCenter, yCenter);
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
