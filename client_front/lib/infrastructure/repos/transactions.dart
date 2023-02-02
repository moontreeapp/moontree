import 'package:client_back/client_back.dart';
import 'package:client_back/server/src/protocol/protocol.dart'
    show TransactionView;
import 'package:client_front/infrastructure/cache/transactions.dart';
import 'package:client_front/infrastructure/calls/transactions.dart';
import 'package:client_front/infrastructure/repos/repository.dart';
import 'package:client_front/infrastructure/services/lookup.dart';

class TransactionHistoryRepo extends Repository<Iterable<TransactionView>> {
  late Wallet wallet;
  late String? symbol;
  late Security? security;
  final int? height;
  late Chain chain;
  late Net net;
  TransactionHistoryRepo({
    Wallet? wallet,
    this.symbol,
    this.security,
    this.height,
    Chain? chain,
    Net? net,
  }) : super(<TransactionView>[]) {
    this.wallet = wallet ?? Current.wallet;
    this.chain = chain ?? security?.chain ?? Current.chain;
    this.net = net ?? security?.net ?? Current.net;
  }

  @override
  bool detectServerError(dynamic resultServer) =>
      resultServer.length == 1 && resultServer.first.error != null;

  @override
  bool detectLocalError(dynamic resultLocal) => resultLocal.length == 0;

  @override
  String extractError(dynamic resultServer) => resultServer.first.error!;

  @override
  Future<Iterable<TransactionView>> fromServer() async =>
      TransactionHistoryCall(
        wallet: wallet,
        chain: chain,
        net: net,
        symbol: symbol,
        security: security,
        height: height,
      )();

  /// server does not give null, local does because local null always indicates
  /// error (missing data), whereas empty might indicate empty data.
  @override
  Iterable<TransactionView>? fromLocal() => TransactionsCache.get(
        wallet: wallet,
        chain: chain,
        net: net,
        symbol: (symbol ?? security?.symbol)!,
        height: height ?? pros.blocks.latest?.height,
      );

  @override
  Future<void> save() async => TransactionsCache.put(
        wallet: wallet,
        chain: chain,
        net: net,
        records: results,
      );
}
