/// a service to hit the serverv2 transactions endpoints: mempool and confirmed
/// compiles info to be sent to the endpoint, gets values for front end
/// rough draft:
/*
*/
//import 'package:client_back/consent/consent_client.dart';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/concepts/holding.dart';
import 'package:magic/domain/server/protocol/comm_balance_view.dart';
import 'package:magic/domain/wallet/wallets.dart';
import 'package:magic/services/calls/server.dart';
import 'package:moontree_utils/moontree_utils.dart';

class HoldingBalancesCall extends ServerCall {
  late List<MnemonicWallet> mnemonicWallets;
  late List<KeypairWallet> keypairWallets;
  late Blockchain blockchain;
  HoldingBalancesCall({
    required this.mnemonicWallets,
    required this.keypairWallets,
    required this.blockchain,
  });

  Future<List<BalanceView>> holdingBalancesBy({
    required Chaindata chain,
    required List<String> roots,
    required List<ByteData> h160s,
  }) async {
    print('chain: $chain');
    print('h160s: $h160s');
    print('roots: $roots');
    //xpub6EtVexS6kuhFVjQNB1qGSUGumEnQVF3xp3926wy92W4GJS7ymvhbWkVzBTjXQ4u8EixkRXmE8N538zei6kCdAyZkWKcZBZ7BSdYm9uNPn9i
    //xpub6EtVexS6kuhFZ22PBCWPC97VNkZ9vufPdrTp2ZDDApasumxt8f8CREs4Zv6nDdFKByp8BPZ5tFFj6ZG4eeerNkDM7mJ2PZfBDeB5LjdRiXY
    //[xpub6DsW75qrcf81yRixgqjPqE59mXo3dZdFjvoiv2MAwoi5YFuE5NPG7KZ7WNsNjzeZJEFt2F13FDVeSuhvSLYfeSBEqsVK8LU6HYwfwL66nkZ, xpub6DsW75qrcf822pzraAivakk7rGQPD9ZRPFTAQySRzCzvnrG6L6e1771hJqhsNGhdhVLMYbzsVjUuhspdut1KXrHRi3nWrM3ioiMPdobVzYA]
    if (roots.isEmpty && h160s.isEmpty) {
      return [];
    }
    return await runCall(() async => await client.balances.get(
          chainName: chain.name,
          xpubkeys: roots,
          h160s: h160s,
        ));
  }

  Future<List<Holding>> call() async {
    final List<BalanceView> holdings = await holdingBalancesBy(
      chain: blockchain.chaindata,
      roots: mnemonicWallets
          .map((e) => e.roots(blockchain))
          .expand((e) => e)
          .toList(),
      h160s: keypairWallets.map((e) => e.h160AsByteData(blockchain)).toList(),
    );

    if (holdings.length == 1 && holdings.first.error != null) {
      // handle
      print('error: ${holdings.first.error}');
      return [];
    }

    for (final txView in holdings) {
      txView.chain = blockchain.name;
    }

    return translate(sortedHoldings(holdings, blockchain.symbol), blockchain);
  }

  List<BalanceView> sortedHoldings(List<BalanceView> records, String coin) {
    // coin
    final head = records.where((e) => e.symbol == coin).toList();

    // alphabetical by display name (tail of symbol)
    final tail = records
        .where((e) => e.symbol != coin)
        .sorted((a, b) => b.symbol.compareTo(a.symbol))
        .toList();
    return head + tail;
  }

  List<Holding> translate(List<BalanceView> records, Blockchain blockchain) => [
        for (final record in records)
          Holding.fromBalanceView(balanceView: record, blockchain: blockchain)
      ];
}
