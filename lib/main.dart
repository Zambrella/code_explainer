import 'dart:math';

import 'package:code_explainer/code_painter.dart';
import 'package:code_explainer/parser.dart';
import 'package:code_explainer/raw_code.dart';
import 'package:code_explainer/token.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
        ),
        fontFamily: 'RobotoMono',
      ),
      themeMode: ThemeMode.light,
      home: const Scaffold(
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
  late final TextEditingController textEditingController;

  // User defined values
  int maxLineChars = 120;
  double fontSize = 18.0;
  double fontHeight = 1.5;

  // Calculated values
  late double codeWidth;
  Iterable<Token>? tokens;
  TextPainter? codeTextPainter;

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController(text: rawCode);
    textEditingController.addListener(onTextChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    codeWidth = calculateCodeTextWidth(
      maxLineChars,
      fontSize,
      fontHeight,
      MediaQuery.of(context).devicePixelRatio,
    );
  }

  void onTextChange() {
    final textValue = textEditingController.text;
    tokens = Parser.parse(textValue);
    final textStyle = TextStyle(
      color: Colors.black,
      fontFamily: 'RobotoMono',
      fontSize: fontSize,
      height: fontHeight,
    );

    final codeTextSpan = TextSpan(
      style: textStyle,
      children: tokens?.map((e) {
        return TextSpan(
          text: e.toString(),
        );
      }).toList(),
    );

    codeTextPainter = TextPainter(
      text: codeTextSpan,
      textDirection: TextDirection.ltr,
    )..layout(
        maxWidth: codeWidth,
        minWidth: codeWidth,
      );

    setState(() {});
  }

  @override
  void dispose() {
    textEditingController.removeListener(onTextChange);
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        //* Left half - Code
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Container(
                color: Colors.grey[300],
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      if (textEditingController.text.isEmpty || tokens == null || codeTextPainter == null) {
                        return const Text('Enter some text');
                      } else {
                        return Container(
                          // To know the height, I need to use a layoutbuilder to get the current width available
                          // Then pass that into (or in my case half of it) into the layout function of the text painter
                          height: codeTextPainter!.size.height,
                          width: double.infinity,
                          // color: Colors.orange,
                          child: CustomPaint(
                            size: Size(double.infinity, min(codeTextPainter!.size.height, constraints.maxHeight)),
                            painter: CodePainter(tokens!, codeTextPainter!),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        //* Right half - Editor
        Container(
          width: 600,
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Input code here:'),
              SizedBox(height: 4),
              Expanded(
                child: TextField(
                  controller: textEditingController,
                  textAlignVertical: TextAlignVertical.top,
                  maxLines: null,
                  expands: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[20],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Slider(
                min: 80,
                max: 160,
                value: maxLineChars.toDouble(),
                onChanged: (value) {
                  // TODO: This could be better
                  setState(() {
                    maxLineChars = value.round();
                    codeWidth = calculateCodeTextWidth(
                      maxLineChars,
                      fontSize,
                      fontHeight,
                      MediaQuery.of(context).devicePixelRatio,
                    );
                  });
                  onTextChange();
                },
              ),
              const SizedBox(height: 8),
              Container(
                height: 100,
                color: Theme.of(context).dividerColor,
                child: Center(
                  child: Text('Buttons to add highlighter'),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  color: Theme.of(context).primaryColorLight,
                  child: const Center(
                    child: Text('List of highlights'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Get the required width in pixels based on the given [maxLineChars] and [fontSize].
double calculateCodeTextWidth(
  int maxLineChars,
  double fontSize,
  double fontHeight,
  double pixelRatio,
) {
  final textStyle = TextStyle(
    color: Colors.black,
    fontFamily: 'RobotoMono',
    fontSize: fontSize,
    height: fontHeight,
  );

  final singleCharTextSpan = TextSpan(
    style: textStyle,
    text: 'a',
  );

  final TextPainter singleCharTextPainter = TextPainter(
    text: singleCharTextSpan,
    textDirection: TextDirection.ltr,
  )..layout();

  final textWidth = singleCharTextPainter.width * maxLineChars;

  return textWidth / pixelRatio;
}
