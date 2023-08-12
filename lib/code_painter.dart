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
    // This is the top left of the text
    final offset = Offset(xCenter, yCenter);

    final tokensToHighlight = tokens.where((token) => token.isHighlighted);

    for (final token in tokensToHighlight) {
      final highlightPaint = Paint()
        ..color = const Color(0xff638965)
        ..style = PaintingStyle.fill;
      final start = token.startPos;
      final end = token.startPos + token.length;
      final textBox = textPainter
          .getBoxesForSelection(
            TextSelection(
              baseOffset: start,
              extentOffset: end,
            ),
          )
          .first;
      final rect = textBox.toRect().shift(offset);
      canvas.drawRect(rect, highlightPaint);
    }

    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
