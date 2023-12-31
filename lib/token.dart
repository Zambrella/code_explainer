import 'package:equatable/equatable.dart';

class Token implements Equatable {
  Token.fromString({
    required this.value,
    required this.lineNumber,
    required this.colNumber,
    required this.startPos,
    this.isHighlighted = false,
    this.annotation,
  }) : assert(
          lineNumber >= 0 && colNumber >= 0,
          'Cannot have negative lineNumber or column number',
        ) {
    type = calculateTokenType(value);
  }

  /// String value of the token.
  final String value;

  /// The line number `this` appears on (i.e. the row). Starts at 1.
  final int lineNumber;

  /// The column number the start of `this` appears on. Starts at 1.
  final int colNumber;

  /// Out of all the tokens, where does `this` start
  final int startPos;

  /// The type of token `this` is. Calculated when constructed.
  late final TokenType type;

  final bool isHighlighted;

  final String? annotation;

  int get length => value.length;

  static TokenType calculateTokenType(String value) {
    if (value.contains('final')) {
      return TokenType.keyword;
    } else {
      return TokenType.string;
    }
  }

  @override
  List<Object?> get props => [
        value,
        type,
        lineNumber,
        colNumber,
      ];

  @override
  bool? get stringify => true;

  @override
  String toString() {
    // return '$value[$colNumber][$lineNumber]';
    return value;
  }
}

enum TokenType {
  keyword,
  string,
}
