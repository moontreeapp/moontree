import 'dart:async';

import 'package:rxdart/rxdart.dart';

import 'package:raven_back/raven_back.dart';
import 'package:raven_back/extensions/stream/maximum.dart';

class PasswordStreams {
  final latest = latestPassword$;
  final exists = passwordExists$;
  final update = BehaviorSubject<String?>.seeded(null);
  final updated = BehaviorSubject<bool?>.seeded(null);
}

final BehaviorSubject<Password?> latestPassword$ = BehaviorSubject.seeded(null)
  ..addStream(res.passwords.changes
      .where((change) => change is Loaded || change is Added)
      .map((change) => change.data)
      .maximum((p1, p2) => p1.id - p2.id));

final Stream<bool> passwordExists$ =
    latestPassword$.map((password) => password == null ? false : true);
