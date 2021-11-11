import 'package:equatable/equatable.dart';

import '../../raven_electrum_client.dart';

/// scriptSig: {
///   asm: 30440220570e370c5d5f559bd37da3f6c463b09e4a61bb57237fead3aa5a3255f30fe09e022035038abb72ccd722700081088f3bf5aab4642fb66df4b79eab88c1d15d064f69[ALL] 03d957a7e1be52d731bcaa3fb0270dbadbe5a81fd7342f8710a70308435174febe,
///   hex: 4730440220570e370c5d5f559bd37da3f6c463b09e4a61bb57237fead3aa5a3255f30fe09e022035038abb72ccd722700081088f3bf5aab4642fb66df4b79eab88c1d15d064f69012103d957a7e1be52d731bcaa3fb0270dbadbe5a81fd7342f8710a70308435174febe}}
class TxScriptSig with EquatableMixin {
  final String asm;
  final String hex;

  TxScriptSig({required this.asm, required this.hex});

  @override
  List<Object?> get props => [asm, hex];
}

/// vin: [{
///   txid: cac2fb61ee5e6edfb9804f19cc4c22994f53931899c0feb423c843ebb93e08c8,
///   vout: 0,
///   scriptSig: {...}],
/// vin: [{
///   coinbase: 038f020e00,
///   sequence: 4294967295}],
class TxVin with EquatableMixin {
  final String? coinbase;
  final int? sequence;
  final String? txid;
  final int? vout;
  final TxScriptSig? scriptSig;

  TxVin({this.coinbase, this.sequence, this.txid, this.vout, this.scriptSig}) {
    if (coinbase != null) {
      assert(sequence != null);
    } else {
      assert(txid != null);
      assert(vout != null);
      assert(scriptSig != null);
    }
  }

  @override
  List<Object?> get props => [coinbase, sequence, txid, vout, scriptSig];
}

/// scriptPubKey: {
///   asm: OP_DUP OP_HASH160 713c2fa8992630a215bc6668822b0acfbc90ead9 OP_EQUALVERIFY OP_CHECKSIG,
///   hex: 76a914713c2fa8992630a215bc6668822b0acfbc90ead988ac,
///   reqSigs: 1,
///   type: pubkeyhash,
///   addresses: [mqqgkYDUkLRLMPvHKhDSjyuwyeNqZhfzVc]}
/// scriptPubKey: {
///   asm: OP_RETURN aa21a9ede2f61c3f71d1defd3fa999dfa36953755c690689799962b48bebd836974e8cf9,
///   hex: 6a24aa21a9ede2f61c3f71d1defd3fa999dfa36953755c690689799962b48bebd836974e8cf9,
///   type: nulldata},
/// scriptPubKey: {
///   asm: OP_DUP OP_HASH160 663b0d46fde6e386f78f12d864a226c7b8050992 OP_EQUALVERIFY OP_CHECKSIG OP_RVN_ASSET 1f72766e7412504f524b5950554e582f41495244524f503200e1f5050000000075,
///   hex: 76a914663b0d46fde6e386f78f12d864a226c7b805099288acc01f72766e7412504f524b5950554e582f41495244524f503200e1f5050000000075,
///   reqSigs: 1,
///   type: transfer_asset,
///   asset: {
///     name: PORKYPUNX\/AIRDROP2,
///     amount: 1},
///   addresses: [RJbjk5VTNxBER4iBq61upUWhHuEeYBHD1J]},
/// scriptPubKey: {
///   asm: OP_DUP OP_HASH160 f7addfa2061fb7752a81b7fbb1de409b62efcb63 OP_EQUALVERIFY OP_CHECKSIG OP_RVN_ASSET 4472766e7112504f524b5950554e582f41495244524f50320001b2c4000000000000011220c48f7efaf0a05d4145f17d95f02858aa7f5fc4e2100bbc6bb666ea07f6a50ce575,
///   hex: 76a914f7addfa2061fb7752a81b7fbb1de409b62efcb6388acc04472766e7112504f524b5950554e582f41495244524f50320001b2c4000000000000011220c48f7efaf0a05d4145f17d95f02858aa7f5fc4e2100bbc6bb666ea07f6a50ce575,
///   reqSigs: 1,
///   type: new_asset,
///   asset: {
///     name: PORKYPUNX\/AIRDROP2,
///     amount: 33,
///     units: 0,
///     reissuable: 0,
///     ipfs_hash: QmbZwXWkqq2gPLX26EH5Gr7qeoZNjYFzYw8E6y5WXHBj2t},
///   addresses: [RXroGqyy9yq7kEKztP4RZWgQrXzmUzMxAL]},
class TxScriptPubKey with EquatableMixin {
  final String asm;
  final String hex;
  final String type;
  final int? reqSigs;
  final List<String>? addresses;
  final String? asset;
  final int? amount;
  final int? units;
  final int? reissuable;
  final String? ipfsHash;

  TxScriptPubKey({
    required this.asm,
    required this.hex,
    required this.type,
    this.reqSigs,
    this.addresses,
    this.asset,
    this.amount,
    this.units,
    this.reissuable,
    this.ipfsHash,
  });

  @override
  List<Object?> get props => [
        asm,
        hex,
        type,
        reqSigs,
        addresses,
        asset,
        amount,
        units,
        reissuable,
        ipfsHash
      ];

  factory TxScriptPubKey.fromScriptPubKey(Map scriptPubKey) =>
      scriptPubKey.keys.contains('asset')
          ? TxScriptPubKey.fromScriptPubKeyNewAsset(scriptPubKey)
          : scriptPubKey.keys.contains('reqSigs')
              ? TxScriptPubKey.fromScriptPubKeyTransaction(scriptPubKey)
              : TxScriptPubKey.fromScriptPubKeyCoinbase(scriptPubKey);

  factory TxScriptPubKey.fromScriptPubKeyCoinbase(Map scriptPubKey) =>
      TxScriptPubKey(
          asm: scriptPubKey['asm'],
          hex: scriptPubKey['hex'],
          type: scriptPubKey['type']);

  factory TxScriptPubKey.fromScriptPubKeyTransaction(Map scriptPubKey) =>
      TxScriptPubKey(
          asm: scriptPubKey['asm'],
          hex: scriptPubKey['hex'],
          type: scriptPubKey['type'],
          reqSigs: scriptPubKey['reqSigs'],
          addresses: <String>[
            for (String addr in scriptPubKey['addresses']) addr
          ]);

  factory TxScriptPubKey.fromScriptPubKeyNewAsset(Map scriptPubKey) =>
      TxScriptPubKey(
        asm: scriptPubKey['asm'],
        hex: scriptPubKey['hex'],
        type: scriptPubKey['type'],
        reqSigs: scriptPubKey['reqSigs'],
        addresses: <String>[
          for (String addr in scriptPubKey['addresses']) addr
        ],
        asset: scriptPubKey['asset']['name'],
        amount: (scriptPubKey['asset']['amount'] as double).toInt(),
        units: scriptPubKey['asset']['units'] ?? 0,
        reissuable: scriptPubKey['asset']['reissuable'] ?? 0,
        ipfsHash: scriptPubKey['asset']['ipfs_hash'],
      );

  @override
  String toString() => 'TxScriptPubKey('
      'asm: $asm, hex: $hex, type: $type, reqSigs: $reqSigs, '
      'addresses: $addresses, asset: $asset, amount: $amount, units: $units, '
      'reissuable: $reissuable, ipfsHash: $ipfsHash)';

  String get memo {
    var x = asm.split(' ');
    var i = 0;
    for (var item in x) {
      if (item == 'OP_RETURN') return x[i + 1];
      i = i + 1;
    }
    return '';
  }

  Map<String, dynamic> get assetData => {
        'type': type,
        'asset': asset,
        'amount': amount,
        'units': units,
        'reissuable': reissuable,
        'ipfsHash': ipfsHash,
      };
}

/// vout: [{
///   value: 5000.0,
///   n: 0,
///   scriptPubKey: {...},
///   valueSat: 500000000000}]
class TxVout with EquatableMixin {
  final double value;
  final int n;
  final int valueSat;
  final TxScriptPubKey scriptPubKey;

  TxVout({
    required this.value,
    required this.n,
    required this.valueSat,
    required this.scriptPubKey,
  });

  @override
  List<Object?> get props => [value, n, valueSat, scriptPubKey];

  String get memo => scriptPubKey.memo;
}

/// https://electrumx-ravencoin.readthedocs.io/en/latest/protocol-methods.html#blockchain-transaction-get
/// { txid: e86f693b46f1ca33480d904acd526079ba7585896cff6d0ae5dcef322d9dc52a,
///   hash: ccabf8580cc55890cba647960bf52760f37caf1923b2f184198e424fd356e3d2,
///   version: 2,
///   size: 173,
///   vsize: 146,
///   locktime: 0,
///   vin: [...],
///   vout: [...],
///   hex: 020000000001010000000000000000000000000000000000000000000000000000000000000000ffffffff05038f020e00ffffffff020088526a740000001976a914713c2fa8992630a215bc6668822b0acfbc90ead988ac0000000000000000266a24aa21a9ede2f61c3f71d1defd3fa999dfa36953755c690689799962b48bebd836974e8cf90120000000000000000000000000000000000000000000000000000000000000000000000000,
///   blockhash: 00000000e2ba484f128e5fff2d767f2d55d035a3d5e797081673c6f8886e58d9,
///   height: 918159,
///   confirmations: 925,
///   time: 1633390166,
///   blocktime: 1633390166}
class Tx with EquatableMixin {
  final String txid;
  final String hash;
  final int version;
  final int size;
  final int vsize;
  final int locktime;
  final List<TxVin> vin;
  final List<TxVout> vout;
  final String hex;
  final String? blockhash;
  final int? height;
  final int? confirmations;
  final int? time;
  final int? blocktime;

  Tx({
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
  List<Object?> get props => [
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
  Future<Tx> getTransaction(String txHash) async {
    var response = Map<String, dynamic>.from(await request(
      'blockchain.transaction.get',
      [txHash, true],
    ));
    var vins = [
      for (Map vin in response['vin'])
        if (vin.keys.contains('coinbase'))
          TxVin(coinbase: vin['coinbase'], sequence: vin['sequence'])
        else
          TxVin(
              txid: vin['txid'],
              vout: vin['vout'],
              sequence: vin['sequence'],
              scriptSig: TxScriptSig(
                  asm: vin['scriptSig']['asm'], hex: vin['scriptSig']['hex']))
    ];
    var vouts = [
      for (var vout in response['vout'])
        TxVout(
            value: vout['value'],
            n: vout['n'],
            valueSat: vout['valueSat'],
            scriptPubKey:
                TxScriptPubKey.fromScriptPubKey(vout['scriptPubKey'] as Map))
    ];
    return Tx(
      txid: response['txid'],
      hash: response['hash'],
      version: response['version'],
      size: response['size'],
      vsize: response['vsize'],
      locktime: response['locktime'],
      vin: vins,
      vout: vouts,
      hex: response['hex'],
      blockhash: response['blockhash'],
      height: response['height'],
      confirmations: response['confirmations'],
      time: response['time'],
      blocktime: response['blocktime'],
    );
  }

  /// returns histories in the same order as txHashes passed in
  Future<List<Tx>> getTransactions(List<String> txHashes) async {
    var futures = <Future<Tx>>[];
    peer.withBatch(() {
      for (var txHash in txHashes) {
        futures.add(getTransaction(txHash));
      }
    });
    List<Tx> results = await Future.wait<Tx>(futures);
    return results;
  }
}


/*
{ txid: 0,
  ... merge with vin.txid, vout.txid
}
/// vout: {
///   txid: 0
///   value: 5000.0,
///   n: 0,
///   scriptPubKey: {...},
///   valueSat: 500000000000}


{ txid: 1,
  vin: [vin1],
  vout: [...],
}
/// vin1: {
///   txid: 1,
///   vout_txid: 0,
///   vout: 0,
///   scriptSig: {...},

any vout that doesn't have a corresponding vin 
(accroding to vin.vout == vout.n && vin.vout_txid = vout.txid) 
is unspent.
*/