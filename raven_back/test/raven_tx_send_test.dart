//import 'package:test/test.dart';
//import 'package:hex/hex.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:raven/account.dart';
import 'package:bip39/bip39.dart' as bip39;

import "package:bs58check/bs58check.dart" as bs58check;

main() {
  test('bitcoinjs-lib (transactions) can create a 1-to-1 Transaction', () {
    var seed = bip39.mnemonicToSeed(
        'smile build brain topple moon scrap area aim budget enjoy polar erosion');
    var account = Account(ravencoinTestnet, seed: seed);
    var node = account.node(4, exposure: NodeExposure.Internal);
    final alice =
        ECPair.fromWIF('L1uyy5qTuGrVXrmrsvHWHgVzW9kKdrp27wBC7Vs6nZDTF2BRUVwy');
    //print(bs58check
    //    .decode('L1uyy5qTuGrVXrmrsvHWHgVzW9kKdrp27wBC7Vs6nZDTF2BRUVwy'));
    //print(node.wallet.base58Priv)
    print(node.wallet.wif);
    final pair = ECPair.fromWIF(node.wallet.wif, network: node.params.network);
    print(alice.privateKey);
    print(Uint8List.fromList(node.wallet.privKey.codeUnits));
    print(node.wallet.privKey);
    print(node.wallet.privKey.codeUnits);
    //print(node.wallet.privateKey);

    print(node.wallet.address);
    print(node.wallet.base58);
    print(node.wallet.base58Priv);
    //tprv8kAJGTKFKXWn4EjqZUtE4YkZZPPBLFz8Tc3puvpMx9aSChVqHqfwEtZeCGY3zmYwusfiYrVWbzQV26xAV5ypeirUooT1qpRFeFYJ3iet5rU
    //m/44'/175'/1'/1/4
    //http://bip32.org/ why is it that this website gives a different address and keys for this?...
    //https://en.bitcoin.it/wiki/List_of_address_prefixes
    //ok, so obviously I don't understand the difference between privKey and base58Priv or how either of those can
    //be translated to the same wif format as alice. butthat's what we need to know.
    //final pair = ECPair(Uint8List.fromList(node.wallet.privKey.codeUnits),
    //    Uint8List.fromList(node.wallet.pubKey.codeUnits),
    //    network: node.params.network, compressed: true);
    final txb = TransactionBuilder(network: node.params.network);
    txb.setVersion(1);
    txb.addInput(
        '56fcc747b8067133a3dc8907565fa1b31e452c98b3f200687cb836f98c3c46ae',
        1); // Alice's previous transaction output, has 5000000 satoshis
    txb.addOutput('mp4dJLeLDNi4B9vZs46nEtM478cUvmx4m7', 4000000);
    // (in)5000000 - (out)4000000 = (fee)1000000, this is the miner fee
    txb.sign(vin: 0, keyPair: pair);
    //// prepare for broadcast to the Bitcoin network, see 'can broadcast a Transaction' below
    //expect(txb.build().toHex(),
    //    '01000000019d344070eac3fe6e394a16d06d7704a7d5c0a10eb2a2c16bc98842b7cc20d561000000006b48304502210088828c0bdfcdca68d8ae0caeb6ec62cd3fd5f9b2191848edae33feb533df35d302202e0beadd35e17e7f83a733f5277028a9b453d525553e3f5d2d7a7aa8010a81d60121029f50f51d63b345039a290c94bffd3180c99ed659ff6ea6b1242bca47eb93b59fffffffff01e02e0000000000001976a91406afd46bcdfd22ef94ac122aa11f241244a37ecc88ac00000000');
  });
}
