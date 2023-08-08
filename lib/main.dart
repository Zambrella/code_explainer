import 'package:code_explainer/code_painter.dart';
import 'package:code_explainer/parser.dart';
import 'package:code_explainer/raw_code.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Explainer(),
        ),
      ),
    );
  }
}

class Explainer extends StatefulWidget {
  const Explainer({super.key});

  @override
  State<Explainer> createState() => _ExplainerState();
}

class _ExplainerState extends State<Explainer> {
  late final tokens = Parser.parse(rawCode);
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: CodePainter(tokens),
    );
  }
}
