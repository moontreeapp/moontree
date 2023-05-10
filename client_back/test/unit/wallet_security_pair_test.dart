// dart --sound-null-safety test test/integration/account_test.dart --concurrency=1 --chain-stack-traces
import 'package:test/test.dart';
import '../fixtures/fixtures.dart' as fixtures;

void main() async {
  setUp(() {
    fixtures.useFixtureSources(1);
  });
}
