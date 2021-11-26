import 'package:raven/raven.dart';
import 'package:rxdart/rxdart.dart';

class AddressStreams {
  final retrieved = addressRetrieved$;
}

//final Stream<Address> addressRetrieved$ = ReplaySubject<Address>().distinctUnique();
final addressRetrieved$ = BehaviorSubject<Address>();
