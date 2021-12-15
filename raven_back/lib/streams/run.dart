import 'package:raven_back/services/transaction_maker.dart';
import 'package:rxdart/rxdart.dart';

class RunStreams {
  final send = send$;
}

final send$ = BehaviorSubject<SendRequest>();
