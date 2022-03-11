import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:convert/convert.dart';
import 'package:bs58/bs58.dart';

import '../lib/src/assets.dart';
import '../lib/src/address.dart';

import '../lib/src/models/networks.dart';

const ONE_SAT = 100000000;

Uint8List decode(String encoded) => Uint8List.fromList(hex.decode(encoded));
String encode(Uint8List decoded) => hex.encode(decoded);

main() {
  group('Assets', () {
    test('Generate asset transfer script, no IPFS', () {
      //76a914f05325e90d5211def86b856c9569e5480820129088ac
      //SCAMCOIN
      //1
      //76a914f05325e90d5211def86b856c9569e5480820129088acc01572766e74085343414d434f494e00e1f5050000000075
      //https://rvn.cryptoscope.io/api/getrawtransaction/?txid=bae95f349f15effe42e75134ee7f4560f53462ddc19c47efdd03f85ef4ab8f40&decode=1

      var data = generateAssetTransferScript(
          decode('76a914f05325e90d5211def86b856c9569e5480820129088ac'),
          'SCAMCOIN',
          1 * ONE_SAT,
          null);
      expect(encode(data),
          '76a914f05325e90d5211def86b856c9569e5480820129088acc01572766e74085343414d434f494e00e1f5050000000075');
    });

    test('Generate asset transfer script, with IPFS', () {
      //76a9140a6e44c0b7a5da84c38ed2900c6b6ce3b8c2e27a88ac
      //MOONTREE1
      //0.9
      //Qmd286K6pohQcTKYqnS1YhWrCiS4gz7Xi34sdwMe9USZ7u
      //76a9140a6e44c0b7a5da84c38ed2900c6b6ce3b8c2e27a88acc03872766e74094d4f4f4e5452454531804a5d05000000001220da203afd5eda1f45deeafb70ae9d5c15907cd32ec2cd747c641fc1e9ab55b8e875
      //https://rvnt.cryptoscope.io/api/getrawtransaction/?txid=aa093a7ac5e8cd1d47ec6354d6df134e7ebfd61e2f0d402e11e6cf7cb3f827bf&decode=1
      var data = generateAssetTransferScript(
          decode('76a9140a6e44c0b7a5da84c38ed2900c6b6ce3b8c2e27a88ac'),
          'MOONTREE1',
          (0.9 * ONE_SAT).toInt(),
          base58.decode('Qmd286K6pohQcTKYqnS1YhWrCiS4gz7Xi34sdwMe9USZ7u'));
      expect(encode(data),
          '76a9140a6e44c0b7a5da84c38ed2900c6b6ce3b8c2e27a88acc03872766e74094d4f4f4e5452454531804a5d05000000001220da203afd5eda1f45deeafb70ae9d5c15907cd32ec2cd747c641fc1e9ab55b8e875');
    });

    test('Generate asset transfer script, Test from address', () {
      //76a914f05325e90d5211def86b856c9569e5480820129088ac
      //SCAMCOIN
      //1
      //76a914f05325e90d5211def86b856c9569e5480820129088acc01572766e74085343414d434f494e00e1f5050000000075
      //https://rvn.cryptoscope.io/api/getrawtransaction/?txid=bae95f349f15effe42e75134ee7f4560f53462ddc19c47efdd03f85ef4ab8f40&decode=1
      var script = Address.addressToOutputScript(
          'RXBurnXXXXXXXXXXXXXXXXXXXXXXWUo9FV', mainnet);
      var data =
          generateAssetTransferScript(script!, 'SCAMCOIN', 1 * ONE_SAT, null);
      expect(encode(data),
          '76a914f05325e90d5211def86b856c9569e5480820129088acc01572766e74085343414d434f494e00e1f5050000000075');
      // To add asset:
      // txb.addOutput(data, 0);
    });
  });
}
