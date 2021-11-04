import 'package:rxdart/rxdart.dart';

class AppStreams {
  final status = appStatus$;
  final active = appActive$;
  final login = login$;
}

/// resumed inactive paused detached
final appStatus$ = BehaviorSubject<String?>.seeded('resumed');
final BehaviorSubject<bool> appActive$ = BehaviorSubject.seeded(true)
  ..addStream(appStatus$.map((status) => status == 'resumed' ? true : false));

final login$ = BehaviorSubject<bool>();
