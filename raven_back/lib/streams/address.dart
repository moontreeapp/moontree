import 'package:raven_back/raven_back.dart';
import 'package:raven_electrum/raven_electrum.dart';
import 'package:rxdart/rxdart.dart';

class AddressStreams {
  final retrieved = BehaviorSubject<Address>();
  final history = BehaviorSubject<List<ScripthashHistory>?>.seeded(null);
  final empty = BehaviorSubject<bool?>.seeded(null);
}

//final Stream<Address> addressRetrieved$ = ReplaySubject<Address>().distinctUnique();
