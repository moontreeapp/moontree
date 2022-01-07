import 'package:rxdart/rxdart.dart';

class AppStreams {
  final status = appStatus$;
  final active = appActive$;
  final login = login$;
  final page = page$;
  final holding = holding$;
}

/// resumed inactive paused detached
final appStatus$ = BehaviorSubject<String?>.seeded('resumed');
final appActive$ = BehaviorSubject<bool>.seeded(true)
  ..addStream(appStatus$.map((status) => status == 'resumed' ? true : false));
final login$ = BehaviorSubject<bool>();
final page$ = BehaviorSubject<String>.seeded('main');
final holding$ = BehaviorSubject<String>.seeded('Ravencoin');
