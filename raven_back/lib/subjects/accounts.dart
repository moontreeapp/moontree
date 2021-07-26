import '../models.dart';

import 'reservoir.dart';

Reservoir accounts = Reservoir(HiveBoxSource('accounts'),
    (account) => Account.fromRecord(account), (account) => account.toRecord());
