import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:ravencoin_wallet/ravencoin_wallet.dart';
import 'package:test/test.dart';
import 'package:hex/hex.dart';

// import '../lib/src/ecpair.dart' show ECPair;
// import '../lib/src/models/networks.dart' as NETWORKS;

final ONE = HEX
    .decode('0000000000000000000000000000000000000000000000000000000000000001');

main() {
  final fixtures = json.decode(
      new File('test/fixtures/ecpair.json').readAsStringSync(encoding: utf8));
  group('ECPair', () {
    group('fromPrivateKey', () {
      test('defaults to compressed', () {
        final keyPair =
            ECPair.fromPrivateKey(ONE as Uint8List, network: bitcoinMainnet);
        expect(keyPair.compressed, true);
      });
      test('supports the uncompressed option', () {
        final keyPair = ECPair.fromPrivateKey(ONE as Uint8List,
            compressed: false, network: bitcoinMainnet);
        expect(keyPair.compressed, false);
      });
      test('supports the network option', () {
        final keyPair = ECPair.fromPrivateKey(ONE as Uint8List,
            network: testnet, compressed: false);
        expect(keyPair.network, testnet);
      });
      (fixtures['valid'] as List).forEach((f) {
        test('derives public key for ${f['WIF']}', () {
          final d = HEX.decode(f['d']);
          final keyPair = ECPair.fromPrivateKey(d as Uint8List,
              compressed: f['compressed'], network: bitcoinMainnet);
          expect(HEX.encode(keyPair.publicKey as List<int>), f['Q']);
        });
      });
      (fixtures['invalid']['fromPrivateKey'] as List).forEach((f) {
        test('throws ' + f['exception'], () {
          final d = HEX.decode(f['d']);
          try {
            expect(ECPair.fromPrivateKey(d as Uint8List), isArgumentError);
          } catch (err) {
            expect((err as ArgumentError).message, f['exception']);
          }
        });
      });
    });
    group('fromPublicKey', () {
      (fixtures['invalid']['fromPublicKey'] as List).forEach((f) {
        test('throws ' + f['exception'], () {
          final Q = HEX.decode(f['Q']);
          try {
            expect(ECPair.fromPublicKey(Q as Uint8List), isArgumentError);
          } catch (err) {
            expect((err as ArgumentError).message, f['exception']);
          }
        });
      });
    });
    group('fromWIF', () {
      (fixtures['valid'] as List).forEach((f) {
        test('imports ${f['WIF']}', () {
          var network = _getNetwork(f);
          final keyPair = ECPair.fromWIF(f['WIF'], networks: bitcoinNetworks);
          expect(HEX.encode(keyPair.privateKey as List<int>), f['d']);
          expect(keyPair.compressed, f['compressed']);
          expect(keyPair.network, network);
        });
      });
      (fixtures['invalid']['fromWIF'] as List).forEach((f) {
        test('throws ' + f['exception'], () {
          //var network =
          _getNetwork(f);
          try {
            expect(ECPair.fromWIF(f['WIF'], networks: bitcoinNetworks),
                isArgumentError);
          } catch (err) {
            expect((err as ArgumentError).message, f['exception']);
          }
        });
      });
    });
    group('toWIF', () {
      (fixtures['valid'] as List).forEach((f) {
        test('export ${f['WIF']}', () {
          //var network =
          _getNetwork(f);
          final keyPair = ECPair.fromWIF(f['WIF'], networks: bitcoinNetworks);
          expect(keyPair.toWIF(), f['WIF']);
        });
      });
    });
    group('makeRandom', () {
      final d = Uint8List.fromList(List.generate(32, (i) => 4));
      final exWIF = 'KwMWvwRJeFqxYyhZgNwYuYjbQENDAPAudQx5VEmKJrUZcq6aL2pv';
      test('allows a custom RNG to be used', () {
        final keyPair = ECPair.makeRandom(
            rng: (size) {
              return d.sublist(0, size);
            },
            network: bitcoinMainnet);
        expect(keyPair.toWIF(), exWIF);
      });
      test('retains the same defaults as ECPair constructor', () {
        final keyPair = ECPair.makeRandom();
        expect(keyPair.compressed, true);
        expect(keyPair.network, mainnet);
      });
      test('supports the options parameter', () {
        final keyPair = ECPair.makeRandom(compressed: false, network: testnet);
        expect(keyPair.compressed, false);
        expect(keyPair.network, testnet);
      });
      test('throws if d is bad length', () {
        rng(int number) {
          return new Uint8List(28);
        }

        try {
          ECPair.makeRandom(rng: rng);
        } catch (err) {
          expect((err as ArgumentError).message, 'Expected Buffer(Length: 32)');
        }
      });
    });
    group('.network', () {
      (fixtures['valid'] as List).forEach((f) {
        test('return ${f['network']} for ${f['WIF']}', () {
          final keyPair = ECPair.fromWIF(f['WIF'], networks: bitcoinNetworks);
          NetworkType? network = _getNetwork(f);
          expect(keyPair.network, network);
        });
      });
    });
  });
}

NetworkType? _getNetwork(f) {
  var network;
  if (f['network'] != null) {
    if (f['network'] == 'bitcoin') {
      network = bitcoinMainnet;
    } else if (f['network'] == 'testnet') {
      network = bitcoinTestnet;
    }
  }
  return network;
}
