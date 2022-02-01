import 'package:rxdart/rxdart.dart';

class AppStreams {
  final status = appStatus$;
  final active = appActive$;
  final login = BehaviorSubject<bool>();
  final verify = BehaviorSubject<bool>.seeded(false);
  final page = BehaviorSubject<String>.seeded('main');
  final setting = BehaviorSubject<String?>.seeded(null);
  final snack = BehaviorSubject<Snack?>.seeded(null);
}

/// resumed inactive paused detached
final appStatus$ = BehaviorSubject<String?>.seeded('resumed');
final appActive$ = BehaviorSubject<bool>.seeded(true)
  ..addStream(appStatus$.map((status) => status == 'resumed' ? true : false));

class Snack {
  final String message;
  final bool positive;
  final String? details; // if they click on the message, popup details
  final String? label; // link label
  final String? link;
  final Map<String, dynamic>? arguments;
  Snack(
      {required this.message,
      this.positive = true,
      this.details,
      this.link,
      this.arguments,
      this.label});
}
