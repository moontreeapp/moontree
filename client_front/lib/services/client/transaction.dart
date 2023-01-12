/// transaction details
import 'dart:typed_data';

import 'package:client_back/client_back.dart';
import 'package:client_back/server/serverv2_client.dart' as server;
import 'package:client_front/services/lookup.dart';
import 'package:moontree_utils/moontree_utils.dart';

class TransactionDetails {
  static const String moontreeUrl =
      'http://24.199.68.139:8080'; //'https://api.moontree.com';
  final server.Client client;

  TransactionDetails() : client = server.Client('$moontreeUrl/');

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
  return

      /// MOCK SERVER
      //await Future.delayed(Duration(seconds: 1), spoofTransactionDetailsView);

      /// SERVER
      await TransactionDetails().transactionDetailsBy(
          hash: hash, chain: ChainNet(chain, net).chaindata);
}

server.TransactionDetailsView spoofTransactionDetailsView() {
  return server.TransactionDetailsView(
    //memo: null,
    memo: 'Qmb86hqUJNCUrpwukZtuWUqunL7GhrkwjZErmWNMbhf5HE'.base58ToByteData,
    containsAssets: false,
  );
}
