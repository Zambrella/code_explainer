import 'dart:math';

import 'package:code_explainer/annotation.dart';
import 'package:code_explainer/annotation_list_item.dart';
import 'package:code_explainer/code_painter.dart';
import 'package:code_explainer/raw_code.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:io' as io;

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
  late final screenshotController = ScreenshotController();

  // User defined values
  int maxLineChars = 120;
  double fontSize = 18.0;
  double fontHeight = 1.5;
  final annotations = <Annotation>[];

  // Calculated values
  late double codeWidth;
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
      MediaQueryData.fromView(View.of(context)).devicePixelRatio,
    );
  }

  void onTextChange() {
    final textValue = textEditingController.text;
    final textStyle = TextStyle(
      color: Colors.black,
      fontFamily: 'RobotoMono',
      fontSize: fontSize,
      height: fontHeight,
    );

    final codeTextSpan = TextSpan(
      style: textStyle,
      text: textValue,
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Screenshot(
                    controller: screenshotController,
                    child: Container(
                      color: Colors.grey[300],
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            if (textEditingController.text.isEmpty || codeTextPainter == null) {
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
                                  painter: CodePainter(annotations, codeTextPainter!),
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
              ElevatedButton(
                onPressed: () async {
                  final image = await screenshotController.capture(
                    pixelRatio: MediaQueryData.fromView(View.of(context)).devicePixelRatio,
                  );
                  String? outputFile = await FilePicker.platform.saveFile(
                    dialogTitle: 'Please select an output file:',
                    fileName: 'Annotation-output.png',
                    type: FileType.image,
                  );
                  if (outputFile == null) {
                    return;
                  }
                  try {
                    io.File returnedFile = io.File(outputFile);
                    await returnedFile.writeAsBytes(image!);
                  } catch (e) {
                    print(e);
                  }
                },
                child: Text('Download'),
              ),
            ],
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
              const SizedBox(height: 16),
              Text('Line width: $maxLineChars'),
              const SizedBox(height: 4),
              SliderTheme(
                data: const SliderThemeData(
                  showValueIndicator: ShowValueIndicator.always,
                ),
                child: Slider(
                  min: 40,
                  max: 160,
                  divisions: 6,
                  label: maxLineChars.toString(),
                  value: maxLineChars.toDouble(),
                  onChanged: (value) {
                    setState(() {
                      maxLineChars = value.round();
                      codeWidth = calculateCodeTextWidth(
                        maxLineChars,
                        fontSize,
                        fontHeight,
                        MediaQueryData.fromView(View.of(context)).devicePixelRatio,
                      );
                    });
                    onTextChange();
                  },
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  color: Theme.of(context).primaryColorLight,
                  child: Center(
                    child: Column(children: [
                      ...annotations
                          .map(
                            (e) => AnnotationListItem(
                              annotation: e,
                              onDelete: (annotationToDelete) {
                                setState(() {
                                  annotations.removeWhere((annotation) => annotation == annotationToDelete);
                                });
                              },
                            ),
                          )
                          .toList(),
                      ...[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final selection = textEditingController.selection;
                              final textController = TextEditingController();
                              final annotation = await showDialog<Annotation>(
                                context: context,
                                builder: (context) {
                                  return SimpleDialog(
                                    contentPadding: const EdgeInsets.all(32),
                                    titleTextStyle: Theme.of(context).textTheme.titleLarge,
                                    title: const Text(
                                      'Annotation',
                                      textAlign: TextAlign.center,
                                    ),
                                    children: [
                                      SizedBox(
                                        width: 700,
                                        child: TextField(
                                          maxLines: null,
                                          controller: textController,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(
                                            Annotation(
                                              startIndex: selection.start,
                                              endIndex: selection.end,
                                              text: textController.text,
                                            ),
                                          );
                                        },
                                        child: const Text('Submit'),
                                      ),
                                    ],
                                  );
                                },
                              );
                              if (mounted && annotation != null) {
                                setState(() {
                                  annotations.add(annotation);
                                });
                              }
                            },
                            icon: Icon(Icons.add),
                            label: Text('Add annotation'),
                          ),
                        ),
                      ]
                    ]),
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
