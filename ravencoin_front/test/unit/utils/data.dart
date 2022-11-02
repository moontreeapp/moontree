import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ravencoin_front/utils/data.dart';

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  test('test populateData', () {
    expect(populateData(MockBuildContext(), {'abc': 123}), {'abc': 123});
    expect(populateData(MockBuildContext(), {}), {});
    expect(populateData(MockBuildContext(), null), {});
  });
}
