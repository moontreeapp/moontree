import 'dart:async';

import 'package:rxdart/rxdart.dart';

import 'package:raven/raven.dart';

class AccountStreams {
  final replay = replayAccount$;
}

final Stream<Account> replayAccount$ = ReplaySubject<Account>()
  ..addStream(accounts.changes
      .where((change) => change is Loaded || change is Added)
      .map((added) => added.data));