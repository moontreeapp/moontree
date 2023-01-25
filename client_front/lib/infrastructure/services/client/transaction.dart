/// transaction details
import 'dart:typed_data';

import 'package:client_back/client_back.dart';
import 'package:client_back/server/serverv2_client.dart' as server;
import 'package:client_front/infrastructure/services/client/mock_flag.dart';
import 'package:client_front/infrastructure/services/client/server_call.dart';
import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:moontree_utils/moontree_utils.dart';

class TransactionDetailsCall extends ServerCall {
  TransactionDetailsCall() : super();

  Future<server.TransactionDetailsView?> transactionDetailsBy({
    required Chaindata chain,
    required ByteData hash,
  }) async =>
      await client.transactionDetails.get(hash: hash, chainName: chain.name);
}

Future<server.TransactionDetailsView?> discoverTransactionDetails({
  Wallet? wallet,
  required ByteData hash,
  Chain? chain,
  Net? net,
}) async {
  chain ??= Current.chain;
  net ??= Current.net;
  final server.TransactionDetailsView? tx = mockFlag

      /// MOCK SERVER
      ? await Future.delayed(Duration(seconds: 1), spoofTransactionDetailsView)

      /// SERVER
      : await TransactionDetailsCall().transactionDetailsBy(
          hash: hash, chain: ChainNet(chain, net).chaindata);

  if (tx?.error != null) {
    // handle
    return null;
  }
  return tx;
}

server.TransactionDetailsView spoofTransactionDetailsView() {
  return server.TransactionDetailsView(
    //memo: null,
    memo: 'Qmb86hqUJNCUrpwukZtuWUqunL7GhrkwjZErmWNMbhf5HE'.base58ToByteData,
    containsAssets: 'ASSETNAME',
  );
}
