import 'package:quiver/collection.dart';
import 'package:raven/models/balance.dart';

class Balances extends DelegatingMap<String, Balance> {
  Balances([Map? balances]) {
    balances?.entries
        .forEach((element) => delegate[element.key] = element.value);
  }

  @override
  final delegate = {};

  void operator +(Balances balances) {
    var tickers = {...delegate.keys, ...balances.keys};
    // mutate delegate
    for (var ticker in tickers) {
      delegate[ticker] = Balance(
          confirmed: (delegate[ticker]?.confirmed ?? 0) +
              (balances[ticker]?.confirmed ?? 0),
          unconfirmed: (delegate[ticker]?.unconfirmed ?? 0) +
              (balances[ticker]?.unconfirmed ?? 0));
    }
  }
}


//import '../records.dart' as records;
//
//class Balances {
//  final Map<String, Balance> balances;
//
//  Balances({required this.balances});
//
//  factory Balances.fromRecord(records.Balances record) {
//    //record.balances.updateAll((String key, records.Balance value) =>
//    //    Balance.fromRecord(value) as Balance); // not allowed to change type
//    //return Balances(balances: record.balances);
//    var newBalances;
//    for (var keyValue in record.balances.entries) {
//      newBalances[keyValue.key] == Balance.fromRecord(keyValue.value);
//    }
//    return Balances(balances: newBalances);
//  }
//
//  factory Balances.fromTwo(Balances one, Balances two) {
//    var tickers = {
//      ...one.balances.keys.toList(),
//      ...two.balances.keys.toList()
//    };
//    return Balances(balances: {
//      for (var ticker in tickers)
//        ticker: Balance(
//          confirmed: (one.balances.keys.contains(ticker)
//                  ? one.balances[ticker]!.confirmed
//                  : 0) +
//              (two.balances.keys.contains(ticker)
//                  ? two.balances[ticker]!.confirmed
//                  : 0),
//          unconfirmed: (one.balances.keys.contains(ticker)
//                  ? one.balances[ticker]!.unconfirmed
//                  : 0) +
//              (two.balances.keys.contains(ticker)
//                  ? two.balances[ticker]!.unconfirmed
//                  : 0),
//        )
//    });
//  }
//
//  records.Balances toRecord() {
//    return records.Balances(balances: balances);
//  }
//
//  // example
//  //@override
//  //bool operator ==(other) => other is Balances && (other.balances == balances);
//
//  //@override
//  //Balances operator ++(other) => other is Balances && (other.balances == balances);
//
//}
//