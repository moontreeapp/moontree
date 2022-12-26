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

  List<TransactionView> transactionHistoryBy(
    Chain chain,
    String symbol,
    List<String> addresses,
  ) async =>
      client.transactionHistory.get(chain, symbol, addresses);
}

Future<bool> discoverTransactionHistory(String deviceId) async {
  final TransactionHistory transactionHistory = TransactionHistory();
  final List<TransactionView> history = await transactionHistory
      .transactionHistoryBy(Current.chain, Current.symbol, Current.addresses);
  return history;
}
*/