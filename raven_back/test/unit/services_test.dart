// dart test test/unit/services_test.dart
import 'package:raven/records.dart';
import 'package:raven/services.dart';
import 'package:raven/reservoirs.dart';
import 'package:test/test.dart';

import 'package:reservoir/map_source.dart';

void main() {
  group('services', () {
    var balanceService = BalanceService(BalanceReservoir(MapSource<Balance>()),
        HistoryReservoir(MapSource<History>()));
    test('make service', () async {
      expect(balanceService is BalanceService, true);
    });
  });
}
