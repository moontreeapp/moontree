/// a service to hit the serverv2 transactions endpoints: mempool and confirmed
/// compiles info to be sent to the endpoint, gets values for front end
/// rough draft:
/*
//import 'package:ravencoin_back/consent/consent_client.dart';
import 'package:ravencoin_back/records/types/chain.dart';

class TransactionHistory {
  TransactionHistory() : client = Client('$moontreeUrl/');
  static const String moontreeUrl = 'https://api.moontree.com';
  static const String textUrl = 'https://moontree.com';

  final Client client;

  List<TransactionView> transactionHistoryBy({
    String chain,
    String net,
    String symbol,
    List<String> pubkeys,
    List<String> addresses,
  }) async =>
      client.transactionHistory.get(
        chain: chain.name, 
        net: net.name, 
        symbol: symbol, 
        pubkeys: pubkeys,
        addresses: addresses,
      );
}

Future<bool> discoverTransactionHistory(String deviceId) async {
  final TransactionHistory transactionHistory = TransactionHistory();
  final List<TransactionView> history = await transactionHistory
      .transactionHistoryBy(
        chain: Current.chain, 
        net: Current.net, 
        symbol: Current.symbol, 
        addresses: Current.addresses, 
        pubkeys: Current.roots);
  return history;
}
*/