import 'package:rxdart/rxdart.dart';

import 'package:raven/globals.dart';
import 'package:raven/raven.dart';
import 'package:raven/utils/maximum_ext.dart';

final passwordExists$ = () {
  var subject = BehaviorSubject<bool>.seeded(false);
  passwords.changes.listen((change) {
    if (change is Loaded || change is Added) {
      subject.add(true);
    }
  });
  return subject;
}();

final Stream<Password> latestPassword$ = passwords.changes
    .where((change) => change is Loaded || change is Added)
    .map((change) => change.data)
    .maximum((p1, p2) => p1.passwordId - p2.passwordId);
