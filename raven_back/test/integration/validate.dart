import 'package:test/test.dart';
import 'package:raven_back/utilities/validate.dart';
import 'package:raven_electrum/connect.dart';
import 'package:raven_electrum/client/base_client.dart';

const PORT = 50002;

void main() {
  test('validate standard assets on chain', () async {
    var channel = await connect('rvn4lyfe.com', port: PORT);
    var client = BaseClient(channel);
    await client.request('server.version', ['', '1.9']);
    for (var letter in List<String>.generate(
        'Z'.codeUnitAt(0) - 'A'.codeUnitAt(0) + 1,
        (index) => String.fromCharCode('A'.codeUnitAt(0) + index))) {
      print('Checking $letter assets');
      var response = await client
          .request('blockchain.asset.get_assets_with_prefix', [letter]);
      response.forEach((element) => {
            if (!isAssetPath(element)) {fail(element)}
          });
    }
    for (var letter in List<String>.generate(
        '9'.codeUnitAt(0) - '0'.codeUnitAt(0) + 1,
        (index) => String.fromCharCode('0'.codeUnitAt(0) + index))) {
      print('Checking $letter assets');
      var response = await client
          .request('blockchain.asset.get_assets_with_prefix', [letter]);
      response.forEach((element) => {
            if (!isAssetPath(element)) {fail(element)}
          });
    }
  });
  test('bad standard assets', () {
    expect(isAssetPath('..'), false);
    expect(isAssetPath('//'), false);
  });
  test('validate qualifier assets on chain', () async {
    var channel = await connect('rvn4lyfe.com', port: PORT);
    var client = BaseClient(channel);
    await client.request('server.version', ['', '1.9']);
    var response =
        await client.request('blockchain.asset.get_assets_with_prefix', ['#']);
    response.forEach((element) => {
          if (!isAssetPath(element)) {fail(element)}
        });
  });
  test('restricted assets on chain and qualifying strings', () async {
    var channel = await connect('rvn4lyfe.com', port: PORT);
    var client = BaseClient(channel);
    await client.request('server.version', ['', '1.9']);
    var response =
        await client.request('blockchain.asset.get_assets_with_prefix', ['\$']);
    for (var element in response) {
      if (!isAssetPath(element)) fail('Restricted: $element');
      var resp =
          await client.request('blockchain.asset.validator_string', [element]);
      if (!isQualifierString(resp['string'])) fail('String: ${resp['string']}');
    }
  });
}
