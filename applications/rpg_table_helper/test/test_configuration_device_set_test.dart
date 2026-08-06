import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_configuration.dart';

void main() {
  test('canonical golden device set is iPad Pro 12.9 landscape only', () {
    expect(testDevices, hasLength(1));
    expect(testDevices.single.name, 'ipad pro 12-9 landscape');
    expect(testDevices.single.size, const Size(1366, 1024));
  });
}
