import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:client_front/domain/utils/data.dart';

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  test('test populateData', () {
    expect(populateData(MockBuildContext(), <String, int>{'abc': 123}),
        <String, int>{'abc': 123});
    expect(populateData(MockBuildContext(), <String, int>{}), <String, int>{});
    expect(populateData(MockBuildContext(), <String, int>{}), <String, int>{});
  });
}
