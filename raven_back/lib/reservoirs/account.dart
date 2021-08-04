import 'package:raven/models/balance.dart';
import 'package:raven/reservoir/reservoir.dart';

class AccountReservoir<Record, Model> extends Reservoir {
  AccountReservoir([source, mapToModel, mapToRecord])
      : super(source ?? HiveBoxSource('accounts'), (account) => account.name,
            [mapToModel, mapToRecord]);
}
