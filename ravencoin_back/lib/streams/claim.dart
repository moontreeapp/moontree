/// CLAIM FEATURE
import 'package:ravencoin_back/records/vout.dart';
import 'package:rxdart/rxdart.dart';
import 'package:moontree_utils/moontree_utils.dart'
    show ReadableIdentifierExtension;

class Claim {
  final BehaviorSubject<Map<String, Set<Vout>>> unclaimed =
      BehaviorSubject<Map<String, Set<Vout>>>.seeded(<String, Set<Vout>>{})
        ..name = 'claim.unclaimed';
}
