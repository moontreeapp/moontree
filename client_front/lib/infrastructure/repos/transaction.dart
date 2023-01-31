import 'dart:typed_data';

import 'package:client_back/records/records.dart';
import 'package:client_back/server/src/protocol/protocol.dart' as protocol;
import 'package:client_front/infrastructure/calls/transaction.dart';
import 'package:client_front/infrastructure/repos/repository.dart';
import 'package:client_front/infrastructure/services/lookup.dart';

class TransactionDetailsRepo extends Repository {
  late Wallet wallet;
  final ByteData hash;
  late Chain chain;
  late Net net;
  late protocol.TransactionDetailsView results;
  TransactionDetailsRepo({
    Wallet? wallet,
    required this.hash,
    Chain? chain,
    Net? net,
  }) : super() {
    this.chain = chain ?? Current.chain;
    this.net = net ?? Current.net;
    this.wallet = wallet ?? Current.wallet;
  }

  /// gets values from server; if that fails, from cache; saves results
  /// and any errors encountered to self. saves to cache automatically.
  @override
  Future<protocol.TransactionDetailsView> get() async {
    final resultServer = await fromServer();
    if (resultServer.error != null) {
      print('TransactionDetailsRepo error: ${resultServer.error}');
      errors[RepoSource.server] = resultServer.error!;
      final resultCache = fromLocal();
      if (resultCache == null) {
        errors[RepoSource.local] = 'cache not implemented'; //'nothing cached'
      } else {
        results = resultCache;
      }
    } else {
      results = resultServer;
      save();
    }
    return resultServer;
  }

  @override
  Future<protocol.TransactionDetailsView> fromServer() async =>
      TransactionDetailsCall(
        wallet: wallet,
        chain: chain,
        net: net,
        hash: hash,
      )();

  /// server does not give null, local does because local null always indicates
  /// error (missing data), whereas empty might indicate empty data.
  @override
  protocol.TransactionDetailsView? fromLocal() => null;

  // not implement for transaction details yet.
  @override
  Future<void> save() async => null;
}
