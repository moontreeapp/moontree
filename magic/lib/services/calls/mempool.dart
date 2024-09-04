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

class TransactionMempoolCall extends ServerCall {
  late List<DerivationWallet> derivationWallets;
  late List<KeypairWallet> keypairWallets;
  late Blockchain blockchain;
  late String? symbol;
  late Security? security;
  final int? height;
  TransactionMempoolCall({
    required this.derivationWallets,
    required this.keypairWallets,
    required this.blockchain,
    this.symbol,
    this.security,
    this.height,
  });

  Future<List<TransactionView>> transactionMempoolBy({
    String? symbol,
    int? height,
    required Chaindata chain,
    required List<String> roots,
    required List<ByteData> h160s,
  }) async =>

      /// we get an error if it's a brand new asset and is still in the mempool
      // ServerpodClientException (ServerpodClientException: Internal server error. Call log id: 676, statusCode = 500)
      await runCall(() async => await client.mempoolTransactions.get(
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
    final List<TransactionView> history = await transactionMempoolBy(
      symbol: serverSymbol,
      height: height,
      chain: blockchain.chaindata,
      roots: derivationWallets
          .map((e) => e.roots(blockchain))
          .expand((e) => e)
          .toList(),
      h160s: keypairWallets.map((e) => e.h160AsByteData(blockchain)).toList(),
    );
    // legit one
    //TransactionView ({"id":null,"error":null,"hash":"decode('IsSdEqG0kp91kVoeqBXDlZYyBPBgYuTpJM+dgs/E14I=', 'base64')","datetime":"-0001-01-01T00:00:00.000Z","fee":226000,"vsize":225,"height":-1,"containsAssets":false,"consolidation":false,"iProvided":626757598223,"iReceived":626757372223,"issueMainBurned":0,"reissueBurned":0,"issueSubBurned":0,"issueUniqueBurned":0,"issueMessageBurned":0,"issueQualifierBurned":0,"issueSubQualifierBurned":0,"issueRestrictedBurned":0,"addTagBurned":0,"burnBurned":0,"chain":null,"symbol":null})
    //bad
    // I think the server is broken, giving us bad/old  mempool  stuff.
    // which makes sense because only the evr crashes and I think it was related to mempool stuff.
    //TransactionView ({"id":null,"error":null,"hash":"decode('5htuA5MpcIzrZUVxXJhG/Wpsj1wMYxO96jkzL5vc64M=', 'base64')","datetime":"-0001-01-01T00:00:00.000Z","fee":501600,"vsize":456,"height":-1,"containsAssets":true,"consolidation":false,"iProvided":37673075821,"iReceived":37672574221,"issueMainBurned":0,"reissueBurned":0,"issueSubBurned":0,"issueUniqueBurned":0,"issueMessageBurned":0,"issueQualifierBurned":0,"issueSubQualifierBurned":0,"issueRestrictedBurned":0,"addTagBurned":0,"burnBurned":0,"chain":null,"symbol":null})
    if (history.length == 1 && history.first.error != null) {
      // handle
      print('history ERROR: ${history.first.error}');
      return [];
    }

    for (final txView in history) {
      txView.chain = blockchain.name;
      txView.symbol = symbol;
      if (txView.datetime == DateTime.utc(-1, 1, 1)) {
        txView.datetime = DateTime.now();
      }
    }
    print('mempool: $history');
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
