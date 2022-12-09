/// CLAIM FEATURE
import 'package:ravencoin_back/records/vout.dart';
import 'package:rxdart/rxdart.dart';

class Claim {
  final BehaviorSubject<Map<String, Set<Vout>>> unclaimed =
      BehaviorSubject<Map<String, Set<Vout>>>.seeded(<String, Set<Vout>>{});
}
