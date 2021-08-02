// dart test test/unit/raven_test.dart
import 'dart:cli';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';
import 'package:raven/raven.dart';

void main() async {
  test('settings listener', () async {
    var settings = BehaviorSubject<Map>();
    settings
        .add({'electrum.url': 'testnet.rvn.rocks', 'electrum.port': '50002'});
    settings
        .add({'electrum.url': 'testnet.rvn.rocks', 'electrum.port': '50002'});
    expect(
        await electrumSettingsStream(settings)
            .timeout(Duration(milliseconds: 1),
                onTimeout: (sink) => sink.add([]))
            .take(2)
            .toList(),
        [
          ['testnet.rvn.rocks', '50002'],
          []
        ]);
  });
}
