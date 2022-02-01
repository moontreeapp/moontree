import 'package:raven_back/raven_back.dart';
import 'package:rxdart/rxdart.dart';

class AddressStreams {
  //final retrieved = BehaviorSubject<Address>();
  final empty = BehaviorSubject<Address?>.seeded(null);
  final history = BehaviorSubject<Iterable<String>?>.seeded(null);
  //final uniqueHistory = uniqueHistory$;
}

//final history$ = BehaviorSubject<Iterable<String>?>.seeded(null);
//final flattenedHistory$ = BehaviorSubject<String?>.seeded(null)
//  ..addStream(history$.where((event) => event != null).expand((i) => i!));
//final uniqueHistory$ = flattenedHistory$.distinctUnique();
