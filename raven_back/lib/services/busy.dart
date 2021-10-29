import 'package:raven/raven.dart';

/// a service that tracks background tasks - if they're busy or not.
/// with this service we can indicate on the front end if background tasks are
/// running, or even what kind of task is running - electrum call or
/// derive address etc.
///
/// it is the individual processes repsonsibility to notify BusyService they are
/// working and when they complete (this is usually done on the waiters).
class BusyService {
  final List<String> busyMessages = [];

  bool get busy => busyMessages.isNotEmpty;

  //String message(String short) => {'client': 'Client is busy'}[short] ?? '';
}
