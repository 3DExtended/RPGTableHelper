import 'package:flutter/material.dart';

extension ColorExtension on String {
  Color parseHexColorRepresentation() {
    final buffer = StringBuffer();

    // Remove '#' if it exists
    var hexString = replaceFirst('#', '');

    // Check if the hex string is 6 or 8 characters
    if (hexString.length == 6) {
      // Add default alpha of 'ff' for fully opaque if it's 6 characters
      buffer.write('ff');
    } else if (hexString.length != 8) {
      throw FormatException(
          "Hex color string should be either 6 or 8 characters long.");
    }

    buffer.write(hexString);
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

extension ColorToHex on Color {
  /// Returns the RGB hex representation (e.g., #ff5733) without alpha.
  String toHex() {
    return '#'
        '${alpha.toRadixString(16).padLeft(2, '0')}'
        '${red.toRadixString(16).padLeft(2, '0')}'
        '${green.toRadixString(16).padLeft(2, '0')}'
        '${blue.toRadixString(16).padLeft(2, '0')}';
  }
}
