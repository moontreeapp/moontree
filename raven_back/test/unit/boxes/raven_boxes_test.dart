// dart --no-sound-null-safety test test/unit/boxes/raven_boxes_test.dart
import 'package:test/test.dart';
import 'package:raven/electrum_client.dart';
import 'package:raven/boxes.dart' as memory;

void main() {
  test('load', () async {
    var truth = memory.Truth.instance;
    await truth.init();
    expect(truth.boxes['settings']!.length, 1);
    await truth.clear();
    expect(truth.boxes['settings']!.length, 0);
    await truth.load();
    expect(truth.boxes['settings']!.length, 1);
    expect(
        truth.boxes['settings']!.get('Electrum Server'), 'testnet.rvn.rocks');
    await truth.boxes['settings']!.put('Electrum Server', 'testnet2.rvn.rocks');
    expect(
        truth.boxes['settings']!.get('Electrum Server'), 'testnet2.rvn.rocks');
  });
}
