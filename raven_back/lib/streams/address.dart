import 'package:raven_back/raven_back.dart';
import 'package:rxdart/rxdart.dart';

class AddressStreams {
  final retrieved = BehaviorSubject<Address>();
  final empty = BehaviorSubject<bool?>.seeded(null);
  final history = history$;
  final uniqueHistory = uniqueHistory$;
}

final history$ = BehaviorSubject<Iterable<String>?>.seeded(null);
final flattenedHistory$ = BehaviorSubject<String?>.seeded(null)
  ..addStream(history$.where((event) => event != null).expand((i) => i!));
final uniqueHistory$ = flattenedHistory$.distinctUnique();
