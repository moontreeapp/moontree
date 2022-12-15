import 'dart:async';

import 'package:rxdart/rxdart.dart';

import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/utilities/stream/maximum.dart';
import 'package:moontree_utils/moontree_utils.dart'
    show ReadableIdentifierExtension;

class PasswordStreams {
  static final BehaviorSubject<
      Password?> latest$ = BehaviorSubject<Password?>.seeded(null)
    ..addStream(pros.passwords.changes
        .where((Change<Password> change) => change is Loaded || change is Added)
        .map((Change<Password> change) => change.record)
        .maximum((Password p1, Password p2) => p1.id - p2.id));

  final BehaviorSubject<Password?> latest = latest$..name = 'password.latest';
  final Stream<bool> exists = latest$
      .map((Password? password) => password != null)
    ..name = 'password.exists';
}
