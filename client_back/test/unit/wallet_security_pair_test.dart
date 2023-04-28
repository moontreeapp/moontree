// dart --sound-null-safety test test/integration/account_test.dart --concurrency=1 --chain-stack-traces
import 'package:test/test.dart';

import 'package:client_back/client_back.dart';

import '../fixtures/fixtures.dart' as fixtures;
import '../fixtures/sets.dart' as sets;

void main() async {
  setUp(() {
    fixtures.useFixtureSources(1);
  });
}
