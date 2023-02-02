import 'dart:typed_data';

import 'package:client_back/records/records.dart';
import 'package:client_back/server/src/protocol/protocol.dart'
    show TransactionDetailsView;
import 'package:client_front/infrastructure/cache/transaction.dart';
import 'package:client_front/infrastructure/calls/transaction.dart';
import 'package:client_front/infrastructure/repos/repository.dart';
import 'package:client_front/infrastructure/services/lookup.dart';

class TransactionDetailsRepo extends Repository<TransactionDetailsView> {
  late Wallet wallet;
  final ByteData hash;
  late Chain chain;
  late Net net;
  TransactionDetailsRepo({
    Wallet? wallet,
    required this.hash,
    Chain? chain,
    Net? net,
  }) : super(TransactionDetailsView(error: 'fallback value')) {
    this.chain = chain ?? Current.chain;
    this.net = net ?? Current.net;
    this.wallet = wallet ?? Current.wallet;
  }

  @override
  Future<TransactionDetailsView> fromServer() async => TransactionDetailsCall(
        wallet: wallet,
        chain: chain,
        net: net,
        hash: hash,
      )();

  /// server does not give null, local does because local null always indicates
  /// error (missing data), whereas empty might indicate empty data.
  @override
  TransactionDetailsView? fromLocal() => TransactionCache.get(
        wallet: wallet,
        chain: chain,
        net: net,
        txHash: hash,
      );

  // not implement for transaction details yet.
  @override
  Future<void> save() async => TransactionCache.put(
        wallet: wallet,
        chain: chain,
        net: net,
        txHash: hash,
        record: results,
      );
}
