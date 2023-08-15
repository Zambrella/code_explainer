import 'package:code_explainer/token.dart';
import 'package:flutter/material.dart';

class CodePainter extends CustomPainter {
  const CodePainter(this.tokens, this.textPainter);

  final Iterable<Token> tokens;
  final TextPainter textPainter;

  @override
  void paint(Canvas canvas, Size size) {
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    final xCenter = (size.width - textPainter.width) / 2;
    final yCenter = (size.height - textPainter.height) / 2;
    // This is the top left of the text
    final offset = Offset(xCenter, yCenter);

    final codeWidth = textPainter.width;
    final remainingSpace = size.width - codeWidth;

    if (remainingSpace < 200) {
      print('Throw error here');
    }

    final tokensToHighlight = tokens.where((token) => token.isHighlighted);

    for (final token in tokensToHighlight) {
      //* Highlight border
      final highlightPaint = Paint()
        ..color = const Color(0xff638965)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
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
      final rect = textBox.toRect().shift(offset).inflate(2);
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
      canvas.drawRRect(rrect, highlightPaint);

      //* Annotation line
      final middlePoint = rect.topCenter;

      final path = Path()
        ..moveTo(middlePoint.dx, middlePoint.dy)
        ..lineTo(middlePoint.dx, middlePoint.dy - 5)
        ..lineTo(xCenter + codeWidth + 20, middlePoint.dy - 5);

      canvas.drawPath(path, highlightPaint);

      //* Annotation text
      const annotationStyle = TextStyle(
        color: Color(0xff638965),
        fontSize: 24,
      );
      final annotationTextSpan = TextSpan(
        style: annotationStyle,
        text: token.annotation,
      );
      final annotationTextPainter = TextPainter(
        text: annotationTextSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.start,
      );
      annotationTextPainter.layout(
        minWidth: (remainingSpace / 2) - 25,
        maxWidth: (remainingSpace / 2) - 25,
      );

      final annotationYOffset = annotationTextPainter.height / 2;

      final annotationOffset = Offset(codeWidth + remainingSpace / 2 + 20, middlePoint.dy - 5 - annotationYOffset);

      annotationTextPainter.paint(canvas, annotationOffset);
    }

    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
