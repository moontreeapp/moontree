import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:convert/convert.dart';
import 'package:bs58/bs58.dart';

import '../lib/src/assets.dart' as assets;
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

      var data = assets.generateAssetTransferScript(
          decode('76a914f05325e90d5211def86b856c9569e5480820129088ac'),
          'SCAMCOIN',
          1 * ONE_SAT);
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
      var data = assets.generateAssetTransferScript(
          decode('76a9140a6e44c0b7a5da84c38ed2900c6b6ce3b8c2e27a88ac'),
          'MOONTREE1',
          (0.9 * ONE_SAT).toInt(),
          ipfsData:
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
          assets.generateAssetTransferScript(script!, 'SCAMCOIN', 1 * ONE_SAT);
      expect(encode(data),
          '76a914f05325e90d5211def86b856c9569e5480820129088acc01572766e74085343414d434f494e00e1f5050000000075');
      // To add asset:
      // txb.addOutput(data, 0);
    });
    test('Generate ownership asset script', () {
      //76a9140bd39e43ac5c47c34fea1a10f570dcdd5d7cdaa488ac
      //JAX!
      //76a9140bd39e43ac5c47c34fea1a10f570dcdd5d7cdaa488acc00972766e6f044a41582175
      //https://rvn.cryptoscope.io/api/getrawtransaction/?txid=8eefce8d264d723b6b8f3cf87bcb400a009d01c2771f94e5cc07af252851aa96&decode=1
      var data = assets.generateAssetOwnershipScript(
          decode('76a9140bd39e43ac5c47c34fea1a10f570dcdd5d7cdaa488ac'), 'JAX');
      expect(encode(data),
          '76a9140bd39e43ac5c47c34fea1a10f570dcdd5d7cdaa488acc00972766e6f044a41582175');
    });
    test('Generate create asset script, no IPFS', () {
      //76a9140bd39e43ac5c47c34fea1a10f570dcdd5d7cdaa488ac
      //JAX
      //21000000000
      //8
      //0
      //76a9140bd39e43ac5c47c34fea1a10f570dcdd5d7cdaa488acc01372766e71034a4158000052acdfb2241d08000075
      //https://rvn.cryptoscope.io/api/getrawtransaction/?txid=8eefce8d264d723b6b8f3cf87bcb400a009d01c2771f94e5cc07af252851aa96&decode=1
      var data = assets.generateAssetCreateScript(
          decode('76a9140bd39e43ac5c47c34fea1a10f570dcdd5d7cdaa488ac'),
          'JAX',
          21000000000 * ONE_SAT,
          8,
          false,
          null);
      expect(encode(data),
          '76a9140bd39e43ac5c47c34fea1a10f570dcdd5d7cdaa488acc01372766e71034a4158000052acdfb2241d08000075');
    });
    test('Generate create asset script, IPFS', () {
      //76a914ebea3e0a3f5637999520e650941c875268fbb4b388ac
      //SCAMCOIN
      //1000000
      //0
      //0
      //QmeGgd16sWq6TNfXy8xzwQWRhv1vZUjP1LBxVnfaHaoV25
      //76a914ebea3e0a3f5637999520e650941c875268fbb4b388acc03a72766e71085343414d434f494e00407a10f35a00000000011220ecb6d45965bcf81b78dfe6744c83030f148cf3be711b538a011323a349df6aae75
      var data = assets.generateAssetCreateScript(
          decode('76a914ebea3e0a3f5637999520e650941c875268fbb4b388ac'),
          'SCAMCOIN',
          1000000 * ONE_SAT,
          0,
          false,
          base58.decode('QmeGgd16sWq6TNfXy8xzwQWRhv1vZUjP1LBxVnfaHaoV25'));
      expect(encode(data),
          '76a914ebea3e0a3f5637999520e650941c875268fbb4b388acc03a72766e71085343414d434f494e00407a10f35a00000000011220ecb6d45965bcf81b78dfe6744c83030f148cf3be711b538a011323a349df6aae75');
    });
    test('Reissue asset script', () {
      //76a91448fb91baa2f03a0abb7cdc853d7f6cbe716481e388ac
      //PKBIT
      //0
      //8
      //1
      //QmYHbwuTfsbwh6Z8rmdTXkgEcLAntinju5SR9x8drn9oQ3
      //76a91448fb91baa2f03a0abb7cdc853d7f6cbe716481e388acc03672766e7205504b42495400000000000000000801122093cd00f45e38dfd4ab071d94999ef24951f131385b3383cd12784e3e68955be075
      var data = assets.generateAssetReissueScript(
          decode('76a91448fb91baa2f03a0abb7cdc853d7f6cbe716481e388ac'),
          'PKBIT',
          0, //Dummy
          0,
          0, //Dummy
          8,
          true,
          base58.decode('QmYHbwuTfsbwh6Z8rmdTXkgEcLAntinju5SR9x8drn9oQ3'));
      expect(encode(data),
          '76a91448fb91baa2f03a0abb7cdc853d7f6cbe716481e388acc03672766e7205504b42495400000000000000000801122093cd00f45e38dfd4ab071d94999ef24951f131385b3383cd12784e3e68955be075');
    });
    //TODO:
    test('asset memo w/ expire', () {});

    test('null qualifier tag', () {
      //#SYSTEM/#GALAXY
      //True
      //RSCHsa4HKH6qQ1cbHWAnQ8AxPHehwMwpkL
      //c014b98ce5280197c46eb0c8423534fe81cbdedf9aef110f2353595354454d2f2347414c41585901
      //https://rvn.cryptoscope.io/api/getrawtransaction/?txid=4ea3369ef6fb57fc26e176ad5903d4684a8c64f641aa0e1f02e5c7428609e060&decode=1
      var address_bytes = base58.decode('RSCHsa4HKH6qQ1cbHWAnQ8AxPHehwMwpkL');
      var data = assets.generateNullQualifierTag('#SYSTEM/#GALAXY',
          address_bytes.sublist(1, address_bytes.length - 4), true);
      expect(encode(data),
          'c014b98ce5280197c46eb0c8423534fe81cbdedf9aef110f2353595354454d2f2347414c41585901');
    });

    test('null verifier string', () {
      //BONO_QUALIFIER
      //c0500f0e424f4e4f5f5155414c4946494552
      //https://rvn.cryptoscope.io/api/getrawtransaction/?txid=477a0b2214475d11e316524b500e29837c6763fec256594c2ca7aa369b15888b&decode=1
      var data = assets.generateNullVerifierTag('BONO_QUALIFIER');
      expect(encode(data), 'c0500f0e424f4e4f5f5155414c4946494552');
    });

    test('global freeze', () {
      //$BONO_MAIN
      //c050500c0a24424f4e4f5f4d41494e00
      //https://rvn.cryptoscope.io/api/getrawtransaction/?txid=2fc0bb7e3a33d12ca08f72add0effc3d059cf63382bebcad96e8923e91c3c537&decode=1
      var data = assets.generateNullGlobalFreezeTag('\$BONO_MAIN', false);
      expect(encode(data), 'c050500c0a24424f4e4f5f4d41494e00');
    });
  });
}
