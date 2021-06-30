// dart --no-sound-null-safety test test/unit/boxes/raven_boxes_test.dart
import 'package:test/test.dart';
import 'package:raven/electrum_client.dart';
import 'package:raven/boxes.dart' as memory;

void main() {
  test('load', () async {
    var Truth = memory.Truth();
    await Truth.load();
    await Truth.clear();
    expect(Truth.boxes['settings']!.length, 0);
    await Truth.load();
    expect(
        Truth.boxes['settings']!.get('Electrum Server'), 'testnet.rvn.rocks');
    await Truth.boxes['settings']!.put('Electrum Server', 'testnet2.rvn.rocks');
    expect(
        Truth.boxes['settings']!.get('Electrum Server'), 'testnet2.rvn.rocks');
  });
}
