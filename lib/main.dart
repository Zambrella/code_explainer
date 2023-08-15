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
  late var tokens = Parser.parse(rawCode);
  late final TextEditingController textEditingController;

  var textPainter = TextPainter(
    text: TextSpan(text: ''),
    textDirection: TextDirection.ltr,
  );

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
    textEditingController.addListener(onTextChange);
  }

  void onTextChange() {
    final textValue = textEditingController.text;
    tokens = Parser.parse(textValue);
    //* Code text
    const textStyle = TextStyle(
      color: Colors.black,
      fontFamily: 'RobotoMono',
      fontSize: 24,
      height: 1.5,
    );
    final textSpan = TextSpan(
      style: textStyle,
      children: tokens.map((e) {
        return TextSpan(
          text: e.toString(),
        );
      }).toList(),
    );
    textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    // TODO: Use a Layout builder and precompute the size the card needs to be
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
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              child: Center(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: CodePainter(tokens, textPainter),
                ),
              ),
            ),
          ),
        ),
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
