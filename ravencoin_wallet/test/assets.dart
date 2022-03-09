import 'package:test/test.dart';
import 'dart:typed_data';
import 'package:convert/convert.dart';

import '../lib/src/assets.dart';

const ONE_SAT = 100000000;

Uint8List decode(String encoded) => Uint8List.fromList(hex.decode(encoded));
String encode(Uint8List decoded) => hex.encode(decoded);

main() {
    group('Assets', () {
        test('Generate asset transfer script, no IPFS', () {
            //76a914f05325e90d5211def86b856c9569e5480820129088ac
            //SCAMCOIN
            //1
            //3176a914f05325e90d5211def86b856c9569e5480820129088acc01572766e74085343414d434f494e00e1f5050000000075
            //https://rvn.cryptoscope.io/api/getrawtransaction/?txid=bae95f349f15effe42e75134ee7f4560f53462ddc19c47efdd03f85ef4ab8f40&decode=1

            var data = generate_asset_transfer_script(decode('76a914f05325e90d5211def86b856c9569e5480820129088ac') ,'SCAMCOIN', 1 * ONE_SAT, null);
            expect(encode(data), '3176a914f05325e90d5211def86b856c9569e5480820129088acc01572766e74085343414d434f494e00e1f5050000000075');
        });
    });
}