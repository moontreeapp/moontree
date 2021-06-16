// dart --no-sound-null-safety test test/raven_tx_test.dart
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:json_rpc_2/json_rpc_2.dart';
import 'package:raven/raven_client.dart';
import 'package:raven/raven_networks.dart';
import 'package:raven/raven_network.dart';
import 'package:raven/wallet_exposure.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:raven/electrum_client.dart';
import 'package:test/test.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bitcoin_flutter/bitcoin_flutter.dart' as bitcoin;

bool skipUnverified(X509Certificate certificate) {
  return true;
}

const connectionTimeout = Duration(seconds: 5);
const aliveTimerDuration = Duration(seconds: 2);
void main() {
  /*

  const { tx, outputs, psbt, fee } = wallet.createTransaction(
      lutxo,
      targets,
      requestedSatPerByte,
      changeAddress,
      isTransactionReplaceable ? HDSegwitBech32Wallet.defaultRBFSequence : HDSegwitBech32Wallet.finalRBFSequence,
    );

  this is from abstract-hd-electrum-wallet... `wallet.getUtxo()`
  so it seems we first of all have to track the utxo set...
  changeAddress will be our next internal address that doesn't have any use yet, so we need to track this or query it in realtime... `const getChangeAddressAsync` -> `wallet.getChangeAddressAsync()`
  psbt is also an unknown...
  /**
   *
   * @param utxos {Array.<{vout: Number, value: Number, txId: String, address: String}>} List of spendable utxos
   * @param targets {Array.<{value: Number, address: String}>} Where coins are going. If theres only 1 target and that target has no value - this will send MAX to that address (respecting fee rate)
   * @param feeRate {Number} satoshi per byte
   * @param changeAddress {String} Excessive coins will go back to that address
   * @param sequence {Number} Used in RBF
   * @param skipSigning {boolean} Whether we should skip signing, use returned `psbt` in that case
   * @param masterFingerprint {number} Decimal number of wallet's master fingerprint
   * @returns {{outputs: Array, tx: Transaction, inputs: Array, fee: Number, psbt: Psbt}}
   */
  createTransaction(utxos, targets, feeRate, changeAddress, sequence, skipSigning = false, masterFingerprint) {...}  
  */
  test('getTransactions', () async {
    var seed = bip39.mnemonicToSeed(
        'smile build brain topple moon scrap area aim budget enjoy polar erosion');
    var network = RavenNetwork(ravencoinTestnet);
    var client = ElectrumClient();
    await client.connect(host: 'testnet.rvn.rocks', port: 50002);
    var version = await client.version('MTWallet', '1.8');
    print(version);

    var wallet = network.getRavenWallet(seed);
    var scriptHash =
        wallet.scriptHashFromAddress(4, exposure: WalletExposure.Internal);
    var history = await client.getTransactions(scriptHash);
    print(history);
  });
}
