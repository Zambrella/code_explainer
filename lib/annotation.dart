import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class Annotation extends ChangeNotifier implements Equatable {
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

  @override
  List<Object?> get props => [startIndex, endIndex];

  @override
  bool? get stringify => false;
}
