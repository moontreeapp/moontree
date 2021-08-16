// dart test test/unit/services_test.dart
import 'package:raven/records.dart';
import 'package:raven/services.dart';
import 'package:raven/reservoirs.dart';
import 'package:test/test.dart';

import '../reservoir/rx_map_source.dart';

void main() {
  group('services', () {
    var balancesService = BalanceService(
        BalanceReservoir(RxMapSource<List<dynamic>, Balance>()),
        HistoryReservoir(RxMapSource<String, History>()));
    test('make service', () async {
      expect(balancesService is BalanceService, true);
    });
  });
}
