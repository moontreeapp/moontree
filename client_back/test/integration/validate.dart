import 'package:stream_channel/stream_channel.dart';
import 'package:test/test.dart';
import 'package:wallet_utils/src/utilities/validation.dart';
import 'package:electrum_adapter/connect.dart';
import 'package:electrum_adapter/client/base_client.dart';

const int PORT = 50002;

void main() {
  test('validate standard assets on chain', () async {
    StreamChannel channel = await connect('rvn4lyfe.com', port: PORT);
    BaseClient client = BaseClient(channel);
    await client.request('server.version', ['', '1.9']);
    for (final String letter in List<String>.generate(
        'Z'.codeUnitAt(0) - 'A'.codeUnitAt(0) + 1,
        (int index) => String.fromCharCode('A'.codeUnitAt(0) + index))) {
      print('Checking $letter assets');
      var response = await client
          .request('blockchain.asset.get_assets_with_prefix', [letter]);
      response.forEach((String element) => {
            if (!isAssetPath(element)) {fail(element)}
          });
    }
    for (final String letter in List<String>.generate(
        '9'.codeUnitAt(0) - '0'.codeUnitAt(0) + 1,
        (int index) => String.fromCharCode('0'.codeUnitAt(0) + index))) {
      print('Checking $letter assets');
      var response = await client
          .request('blockchain.asset.get_assets_with_prefix', [letter]);
      response.forEach((String element) => {
            if (!isAssetPath(element)) {fail(element)}
          });
    }
  });
  test('bad standard assets', () {
    expect(isAssetPath('..'), false);
    expect(isAssetPath('//'), false);
  });
  test('validate qualifier assets on chain', () async {
    StreamChannel channel = await connect('rvn4lyfe.com', port: PORT);
    BaseClient client = BaseClient(channel);
    await client.request('server.version', ['', '1.9']);
    var response =
        await client.request('blockchain.asset.get_assets_with_prefix', ['#']);
    response.forEach((String element) => {
          if (!isAssetPath(element)) {fail(element)}
        });
  });
  test('restricted assets on chain and qualifying strings', () async {
    StreamChannel channel = await connect('rvn4lyfe.com', port: PORT);
    BaseClient client = BaseClient(channel);
    await client.request('server.version', ['', '1.9']);
    var response =
        await client.request('blockchain.asset.get_assets_with_prefix', ['\$']);
    for (final String element in response as Iterable<String>) {
      if (!isAssetPath(element)) fail('Restricted: $element');
      var resp =
          await client.request('blockchain.asset.validator_string', [element]);
      if (!isQualifierString(resp['string'] as String)) {
        fail('String: ${resp['string']}');
      }
    }
  });
}
