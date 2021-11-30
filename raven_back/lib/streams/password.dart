import 'dart:async';

import 'package:rxdart/rxdart.dart';

import 'package:raven_back/raven_back.dart';
import 'package:raven_back/utils/maximum_ext.dart';

class PasswordStreams {
  final latest = latestPassword$;
  final exists = passwordExists$;
}

final BehaviorSubject<Password?> latestPassword$ = BehaviorSubject.seeded(null)
  ..addStream(passwords.changes
      .where((change) => change is Loaded || change is Added)
      .map((change) => change.data)
      .maximum((p1, p2) => p1.passwordId - p2.passwordId));

final Stream<bool> passwordExists$ =
    latestPassword$.map((password) => password == null ? false : true);
