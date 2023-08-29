import 'package:flutter/material.dart';

class Annotation extends ChangeNotifier {
  Annotation({
    required this.startIndex,
    required this.endIndex,
    required this.text,
  });

  final int startIndex;
  final int endIndex;
  String text;

  int get length => endIndex - startIndex;

  void updateAnnotationText(String newText) {
    text = newText;
    notifyListeners();
  }

  @override
  String toString() {
    return 'Annotation(start: $startIndex, end: $endIndex, text: $text)';
  }
}
