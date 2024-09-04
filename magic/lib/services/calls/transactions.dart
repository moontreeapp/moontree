/// a service to hit the serverv2 transactions endpoints: mempool and confirmed
/// compiles info to be sent to the endpoint, gets values for front end
/// rough draft:
/*
*/
//import 'package:client_back/consent/consent_client.dart';
import 'dart:typed_data';

import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/concepts/money/security.dart';
import 'package:magic/domain/concepts/transaction.dart';
import 'package:magic/domain/server/serverv2_client.dart';
import 'package:magic/domain/wallet/wallets.dart';
import 'package:magic/services/calls/server.dart';
import 'package:moontree_utils/moontree_utils.dart';

class TransactionHistoryCall extends ServerCall {
  late List<DerivationWallet> derivationWallets;
  late List<KeypairWallet> keypairWallets;
  late Blockchain blockchain;
  late String? symbol;
  late Security? security;
  final int? height;
  TransactionHistoryCall({
    required this.derivationWallets,
    required this.keypairWallets,
    required this.blockchain,
    this.symbol,
    this.security,
    this.height,
  });

  Future<List<TransactionView>> transactionHistoryBy({
    String? symbol,
    int? height,
    required Chaindata chain,
    required List<String> roots,
    required List<ByteData> h160s,
  }) async =>
      await runCall(() async => await client.transactions.get(
            symbol: symbol,
            backFromHeight: height,
            chainName: chain.name,
            xpubkeys: roots,
            h160s: h160s,
          ));

  Future<List<TransactionDisplay>> call() async {
    final String? serverSymbol = ((security?.isCoin ?? true) &&
            (symbol == null || symbol == blockchain.symbol || symbol == '')
        ? null
        : security?.symbol ?? symbol);
    symbol ??=
        serverSymbol == null ? blockchain.symbol : security?.symbol ?? symbol;
    final List<TransactionView> history = await transactionHistoryBy(
      symbol: serverSymbol,
      height: height,
      chain: blockchain.chaindata,
      roots: derivationWallets
          .map((e) => e.roots(blockchain))
          .expand((e) => e)
          .toList(),
      h160s: keypairWallets.map((e) => e.h160AsByteData(blockchain)).toList(),
    );

    if (history.length == 1 && history.first.error != null) {
      // handle
      print('history.first.error: ${history.first.error}');
      return [];
    }

    for (final txView in history) {
      txView.chain = blockchain.name;
      txView.symbol = symbol;
    }
    print('trasnsactions: ${history.map((e) => [e.height])}');
    return translate(history, blockchain);
  }

  List<TransactionDisplay> translate(
    List<TransactionView> records,
    Blockchain blockchain,
  ) =>
      [
        for (final record in records)
          TransactionDisplay.fromTransactionView(
              transactionView: record, blockchain: blockchain)
      ];
}
