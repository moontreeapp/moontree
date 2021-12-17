import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raven_front/utils/extensions.dart';

void main() {
  test('test extension replace', () {
    expect(
        TextStyle(fontWeight: FontWeight.normal)
            .replace(fontWeight: FontWeight.bold)
            .fontWeight,
        FontWeight.bold);
  });
}
