/// CLAIM FEATURE
import 'package:ravencoin_back/records/vout.dart';
import 'package:rxdart/rxdart.dart';

class Claim {
  final unclaimed = BehaviorSubject<Set<Vout>>.seeded(<Vout>{});
}
