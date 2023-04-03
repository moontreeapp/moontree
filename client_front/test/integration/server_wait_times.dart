/// see cubits, put this test in them directly

import 'package:flutter_test/flutter_test.dart';
import 'package:moontree_utils/moontree_utils.dart';

extension MinMaxOfAIteratableDouble on Iterable<double> {
  double get avg => sumDouble() / length;
}

void main() {
  test('call holdings endpoint several times', () {
    var waitTimes = <double>[];
    // see holdings cubit
    /* -- testing await times
      var waits = <int>[];
      for (final _ in range(20)) {
        final Stopwatch s = Stopwatch()..start();
        await discoverHoldingBalances(wallet: wallet);
        final x = s.elapsed.inMilliseconds;
        waits.add(x);
        print(x);
      }
      print('avg: ${waits.fold<int>(0, (p, e) => p + e) / waits.length}');
      print('max: ${waits.fold<int>(0, (p, e) => p > e ? p : e)}');
      print('min: ${waits.fold<int>(10000000, (p, e) => p < e ? p : e)}');
      */
    print(waitTimes);
    //expect(waitTimes.avg < 1.0, true);
    //expect(waitTimes.max < 5.0, true);
  });

  test('call transactions endpoint several times', () {
    var waitTimes = <double>[];

    /// move to transactions cubit to test
    /* testing await times
      var waits = <int>[];
      for (final _ in range(20)) {
        final Stopwatch s = Stopwatch()..start();
        await discoverTransactionHistory(
          wallet: state.wallet,
          security: state.security,
        );
        final x = s.elapsed.inMilliseconds;
        waits.add(x);
        print(x);
      }
      print('avg: ${waits.fold<int>(0, (p, e) => p + e) / waits.length}');
      print('max: ${waits.fold<int>(0, (p, e) => p > e ? p : e)}');
      print('min: ${waits.fold<int>(100000000, (p, e) => p < e ? p : e)}');
      */
    print(waitTimes);
    //expect(waitTimes.avg < 1.0, true);
    //expect(waitTimes.max < 5.0, true);
  });
}
