import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quest_keeper/helpers/color_extension.dart';

void main() {
  group('ColorExtension.parseHexColorRepresentation', () {
    test('Parses 6-character hex color (RGB) without alpha', () {
      expect(
          "#ff5733".parseHexColorRepresentation(), equals(Color(0xffff5733)));
    });

    test('Parses 8-character hex color (ARGB) with alpha', () {
      expect(
          "#80ff5733".parseHexColorRepresentation(), equals(Color(0x80ff5733)));
    });

    test('Parses 6-character hex color without # prefix', () {
      expect("ff5733".parseHexColorRepresentation(), equals(Color(0xffff5733)));
    });

    test('Parses 8-character hex color without # prefix', () {
      expect(
          "80ff5733".parseHexColorRepresentation(), equals(Color(0x80ff5733)));
    });

    test('Throws FormatException on invalid hex length (5 characters)', () {
      expect(
          () => "#12345".parseHexColorRepresentation(), throwsFormatException);
    });

    test('Throws FormatException on invalid hex length (9 characters)', () {
      expect(() => "#123456789".parseHexColorRepresentation(),
          throwsFormatException);
    });

    test('Throws FormatException on non-hex characters', () {
      expect(
          () => "#gg5733".parseHexColorRepresentation(), throwsFormatException);
    });
  });
}
