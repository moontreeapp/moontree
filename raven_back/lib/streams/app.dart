import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

class AppStreams {
  final status = appStatus$;
  final active = appActive$;
  final login = login$;
  final page = page$;
  final spending = spending$;
}

/// resumed inactive paused detached
final appStatus$ = BehaviorSubject<String?>.seeded('resumed');
final appActive$ = BehaviorSubject<bool>.seeded(true)
  ..addStream(appStatus$.map((status) => status == 'resumed' ? true : false));
final login$ = BehaviorSubject<bool>();
final page$ = BehaviorSubject<String>.seeded('main');

// used in pages.send and BalanceHeader of raven_front
final spending$ =
    BehaviorSubject<Tuple2<String, double>>.seeded(Tuple2('Ravencoin', 0));
