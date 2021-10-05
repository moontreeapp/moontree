import 'package:equatable/equatable.dart';

import '../raven_electrum_client.dart';

class TransactionVin with EquatableMixin {
  final String coinbase;
  final int sequence;

  TransactionVin({required this.coinbase, required this.sequence});

  @override
  List<Object?> get props => [coinbase, sequence];
}

class ScriptPubKey with EquatableMixin {
  final String asm;
  final String hex;
  final String type;
  final int? reqSigs;
  final List? addresses;

  ScriptPubKey({
    required this.asm,
    required this.hex,
    required this.type,
    this.reqSigs,
    this.addresses,
  });

  @override
  List<Object?> get props => [asm, hex, reqSigs, type, addresses];
}

class TransactionVout with EquatableMixin {
  final double value;
  final int n;
  final int valueSat;
  final ScriptPubKey scriptPubKey;

  TransactionVout({
    required this.value,
    required this.n,
    required this.valueSat,
    required this.scriptPubKey,
  });

  @override
  List<Object?> get props => [value, n, valueSat, scriptPubKey];
}

/// https://electrumx-ravencoin.readthedocs.io/en/latest/protocol-methods.html#blockchain-transaction-get
class Transaction with EquatableMixin {
  final String txid;
  final String hash;
  final int version;
  final int size;
  final int vsize;
  final int locktime;
  final List<TransactionVin> vin;
  final List<TransactionVout> vout;
  final String hex;
  final String blockhash;
  final int height;
  final int confirmations;
  final int time;
  final int blocktime;

  Transaction({
    required this.txid,
    required this.hash,
    required this.version,
    required this.size,
    required this.vsize,
    required this.locktime,
    required this.vin,
    required this.vout,
    required this.hex,
    required this.blockhash,
    required this.height,
    required this.confirmations,
    required this.time,
    required this.blocktime,
  });

  @override
  List<Object> get props => [
        txid,
        hash,
        version,
        size,
        vsize,
        locktime,
        vin,
        vout,
        hex,
        blockhash,
        height,
        confirmations,
        time,
        blocktime,
      ];

  @override
  String toString() {
    return 'Transaction(txid: $txid, hash: $hash, blockhash: $blockhash, '
        'blocktime: $blocktime, confirmations: $confirmations, height: $height, '
        'hex: $hex, locktime: $locktime, size: $size, vsize: $vsize, time: $time, '
        'txid: $txid, version: $version, vin: $vin, vout: $vout)';
  }
}

extension GetTransactionMethod on RavenElectrumClient {
  Future<Transaction> getTransaction(String txHash) async {
    var response = Map<String, dynamic>.from(await request(
      'blockchain.transaction.get',
      [txHash, true],
    ));
    var vin = [
      for (var v in response['vin'])
        TransactionVin(coinbase: v['coinbase'], sequence: v['sequence'])
    ];
    var vout = [
      for (var v in response['vout'])
        TransactionVout(
            value: v['value'],
            n: v['n'],
            valueSat: v['valueSat'],
            scriptPubKey: ScriptPubKey(
                asm: v['scriptPubKey']['asm'],
                hex: v['scriptPubKey']['hex'],
                reqSigs: v['scriptPubKey']['reqSigs'],
                type: v['scriptPubKey']['type'],
                addresses: v['scriptPubKey']['addresses']))
    ];
    return Transaction(
      txid: response['txid'],
      hash: response['hash'],
      version: response['version'],
      size: response['size'],
      vsize: response['vsize'],
      locktime: response['locktime'],
      vin: vin,
      vout: vout,
      hex: response['hex'],
      blockhash: response['blockhash'],
      height: response['height'],
      confirmations: response['confirmations'],
      time: response['time'],
      blocktime: response['blocktime'],
    );
  }

  /// returns histories in the same order as txHashes passed in
  Future<List<Transaction>> getTransactions(List<String> txHashes) async {
    var futures = <Future<Transaction>>[];
    peer.withBatch(() {
      for (var txHash in txHashes) {
        futures.add(getTransaction(txHash));
      }
    });
    List<Transaction> results = await Future.wait<Transaction>(futures);
    return results;
  }
}
