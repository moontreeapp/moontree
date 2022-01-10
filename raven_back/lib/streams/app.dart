import 'package:rxdart/rxdart.dart';

class AppStreams {
  final status = appStatus$;
  final active = appActive$;
  final login = login$;
  final page = page$;
  final spending = Spending();
}

/// resumed inactive paused detached
final appStatus$ = BehaviorSubject<String?>.seeded('resumed');
final appActive$ = BehaviorSubject<bool>.seeded(true)
  ..addStream(appStatus$.map((status) => status == 'resumed' ? true : false));
final login$ = BehaviorSubject<bool>();
final page$ = BehaviorSubject<String>.seeded('main');

// used in pages.send and BalanceHeader of raven_front
class Spending {
  final symbol = symbol$;
  final amount = amount$;
  final fee = fee$;
}

final symbol$ = BehaviorSubject<String>.seeded('Ravencoin');
final amount$ = BehaviorSubject<double>.seeded(0.0);
final fee$ = BehaviorSubject<String>.seeded('Standard');
