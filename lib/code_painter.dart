import 'dart:math';

import 'package:code_explainer/annotation.dart';
import 'package:flutter/material.dart';

class CodePainter extends CustomPainter {
  const CodePainter(this.annotations, this.textPainter);

  final Iterable<Annotation> annotations;
  final TextPainter textPainter;

  @override
  void paint(Canvas canvas, Size size) {
    const xCenter = 0.0; //(size.width - textPainter.width) / 2;
    const yCenter = 0.0; //(size.height - textPainter.height) / 2;
    // This is the top left of the text
    const offset = Offset(xCenter, yCenter);

    final codeWidth = textPainter.width;
    final remainingSpace = size.width - codeWidth;

    final codeTextBoxPaint = Paint()..color = Colors.yellow;

    canvas.drawRect(Rect.fromLTWH(0, 0, textPainter.width, textPainter.height), codeTextBoxPaint);

    for (final annotation in annotations) {
      //* Highlight border
      final highlightPaint = Paint()
        ..color = const Color(0xff638965)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      final start = annotation.startIndex;
      final end = annotation.endIndex;
      final textBox = textPainter.getBoxesForSelection(
        TextSelection(
          baseOffset: start,
          extentOffset: end,
        ),
      );

      var finalRect = textBox.first.toRect();
      for (final element in textBox) {
        finalRect = finalRect.expandToInclude(element.toRect());
      }

      final rect = finalRect.shift(offset).inflate(2);
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
        fontSize: 22,
      );
      final annotationTextSpan = TextSpan(
        style: annotationStyle,
        text: annotation.text,
      );
      final annotationTextPainter = TextPainter(
        text: annotationTextSpan,
        textDirection: TextDirection.ltr,
      );
      annotationTextPainter.layout(
        maxWidth: remainingSpace - 25,
      );
      final lineMetrics = annotationTextPainter.computeLineMetrics();
      // For some reason the width of the text painter isn't reporting properly but this works by finding the longest line
      final lmWidth = lineMetrics.reduce((value, element) => value.width > element.width ? value : element).width;

      final annotationYOffset = annotationTextPainter.height / 2;

      final annotationOffset = Offset(codeWidth + 20, middlePoint.dy - 5 - annotationYOffset);

      final annotationRect = Rect.fromLTWH(
        annotationOffset.dx,
        annotationOffset.dy,
        lmWidth,
        annotationTextPainter.height,
      ).inflate(6);

      final annotationRectPainter = Paint()..color = Colors.red;

      canvas.drawRect(annotationRect, annotationRectPainter);
      annotationTextPainter.paint(canvas, annotationOffset);
    }

    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
