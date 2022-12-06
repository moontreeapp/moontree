import 'dart:async';

import 'package:rxdart/rxdart.dart';

import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/utilities/stream/maximum.dart';

class PasswordStreams {
  final BehaviorSubject<Password?> latest = latestPassword$;
  final Stream<bool> exists = passwordExists$;
}

final BehaviorSubject<Password?> latestPassword$ =
    BehaviorSubject<Password?>.seeded(null)
      ..addStream(pros.passwords.changes
          .where(
              (Change<Password> change) => change is Loaded || change is Added)
          .map((Change<Password> change) => change.record)
          .maximum((Password p1, Password p2) => p1.id - p2.id));

final Stream<bool> passwordExists$ =
    latestPassword$.map((Password? password) => password != null);
