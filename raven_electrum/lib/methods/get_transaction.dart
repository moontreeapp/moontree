import 'package:equatable/equatable.dart';

import '../raven_electrum_client.dart';

/// https://electrumx-ravencoin.readthedocs.io/en/latest/protocol-methods.html#blockchain-transaction-get
class Transaction with EquatableMixin {
  String txHash;
  String blockHash;
  int blockTime; // height?
  int confirmations;
  String hash;
  String hex;
  int lockTime;
  int size;
  int time;
  String txid;
  String version;
  List<Map> vin;
  List<Map> vout;
  Transaction({
    required this.txHash,
    required this.blockHash,
    required this.blockTime,
    required this.confirmations,
    required this.hash,
    required this.hex,
    required this.lockTime,
    required this.size,
    required this.time,
    required this.txid,
    required this.version,
    required this.vin,
    required this.vout,
  });

  @override
  List<Object> get props => [
        txHash,
        blockHash,
        blockTime,
        confirmations,
        hash,
        hex,
        lockTime,
        size,
        time,
        txid,
        version,
        vin,
        vout,
      ];

  @override
  String toString() {
    return 'Transaction(txHash: $txHash, blockHash: $blockHash, '
        'blockTime: $blockTime, confirmations: $confirmations, hash: $hash, '
        'hex: $hex, lockTime: $lockTime, size: $size, time: $time, '
        'txid: $txid, version: $version, vin: $vin, vout: $vout)';
  }
}

extension GetHistoryMethod on RavenElectrumClient {
  Future<Transaction> getTransaction(String txHash) async => (await request(
        'blockchain.transaction.get',
        [txHash, true],
      ))
          .map((response) => Transaction(
                txHash: response['tx_hash'],
                blockHash: response['blockhash'],
                blockTime: response['blocktime'],
                confirmations: response['confirmations'],
                hash: response['hash'],
                hex: response['hex'],
                lockTime: response['locktime'],
                size: response['size'],
                time: response['time'],
                txid: response['txid'],
                version: response['version'],
                vin: response['vin'],
                vout: response['vout'],
              ));

  /// returns histories in the same order as txHashes passed in
  Future<List<Transaction>> getTransactions(
    List<String> txHashes,
  ) async {
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
