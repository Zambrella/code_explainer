import 'package:code_explainer/token.dart';

class Parser {
  const Parser();

  static Iterable<Token> parse(String text) {
    final split = text.split('');

    const whitespace = ' ';
    const newLine = '\n';

    // Current sequence of characters
    final sequence = <String>[];
    final tokens = <Token>[];

    // Updated only after all other actions have taken place
    var currentColNumber = 0;

    // Updated when there is a new line character
    var currentLineNumber = 0;

    void bankSequence() {
      final word = sequence.reduce((value, element) => '$value$element');
      print(word);
      final token = Token.fromString(
        value: word,
        colNumber: currentColNumber - word.length,
        lineNumber: currentLineNumber,
      );
      tokens.add(token);
      sequence.clear();
    }

    for (var c in split) {
      // Switch case on code unit to act on important characters.
      switch (c.codeUnits.first.toRadixString(16)) {
        // Whitespace
        case "20":
          if (sequence.isNotEmpty) {
            bankSequence();
          }
          tokens.add(
            Token.fromString(
              value: whitespace,
              colNumber: currentColNumber,
              lineNumber: currentLineNumber,
            ),
          );
          currentColNumber++;
        // New Line
        case "a":
          if (sequence.isNotEmpty) {
            bankSequence();
          }
          final token = Token.fromString(
            value: newLine,
            colNumber: currentColNumber,
            lineNumber: currentLineNumber,
          );
          tokens.add(token);
          currentColNumber = 0;
          currentLineNumber++;
        case _:
          sequence.add(c);
          currentColNumber++;
      }
    }
    return tokens;
  }
}