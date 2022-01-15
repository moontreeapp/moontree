import 'package:rxdart/rxdart.dart';

class AppStreams {
  final status = appStatus$;
  final active = appActive$;
  final login = BehaviorSubject<bool>();
  final page = BehaviorSubject<String>.seeded('main');
  final spending = Spending();
  final import = Importing();
  final snack = snack$;
}

/// resumed inactive paused detached
final appStatus$ = BehaviorSubject<String?>.seeded('resumed');
final appActive$ = BehaviorSubject<bool>.seeded(true)
  ..addStream(appStatus$.map((status) => status == 'resumed' ? true : false));

// used in pages.send and BalanceHeader of raven_front
class Spending {
  final symbol = BehaviorSubject<String>.seeded('Ravencoin');
  final amount = BehaviorSubject<double>.seeded(0.0);
  final fee = BehaviorSubject<String>.seeded('Standard');
  final success = BehaviorSubject<bool?>.seeded(null);
}

class ImportRequest {
  final String text;
  final String accountId;
  ImportRequest({required this.text, required this.accountId});
  @override
  String toString() => 'ImportRequest(text=$text, accountId=$accountId)';
}

class Importing {
  final attempt = BehaviorSubject<ImportRequest?>.seeded(null);
  final success = BehaviorSubject<bool?>.seeded(null);
}

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

final snack$ = BehaviorSubject<Snack?>.seeded(null);
