import 'dart:async';

import 'package:collection/src/iterable_extensions.dart';
import 'package:rxdart/rxdart.dart';

class BusyMessage {
  final String type;
  final String message;
  BusyMessage({required this.type, this.message = ''});

  @override
  String toString() => 'BusyMessage($type, $message)';

  @override
  bool operator ==(other) =>
      (other as BusyMessage).type == type && other.message == message;
}

/// a service that tracks background tasks - if they're busy or not.
/// with this service we can indicate on the front end if background tasks are
/// running, or even what kind of task is running - electrum call or
/// derive address etc.
///
/// it is the individual processes repsonsibility to notify BusyService they are
/// working and when they complete (this is usually done on the waiters).
class BusyService {
  final List<String> clientMessages = [];
  final List<String> processMessages = [];
  final BehaviorSubject<String?> client = BehaviorSubject<String?>();
  final BehaviorSubject<String?> process = BehaviorSubject<String?>();
  late Timer timer;

  BusyService() {
    // there's a limit to how long any download should take.
    // we've seen threads silently disappearing so messages
    // are left on the stack which should have been removed.
    timer = Timer.periodic(Duration(seconds: 5),
        (Timer t) => clientMessages.remove(clientMessages.firstOrNull));
  }

  void clientAdd(String value) {
    clientMessages.add(value);
    client.add(value);
  }

  void processAdd(String value) {
    processMessages.add(value);
    process.add(value);
  }

  bool clientRemove(String value) {
    var result = clientMessages.remove(value);
    client.add(null);
    return result;
  }

  bool processRemove(String value) {
    var result = processMessages.remove(value);
    process.add(null);
    return result;
  }

  void dispose() {
    client.close();
    process.close();
    timer.cancel();
  }

  bool get clientBusy => clientMessages.isNotEmpty;
  bool get busy => clientMessages.isNotEmpty || processMessages.isNotEmpty;

  void clear() {
    clientMessages.clear();
    processMessages.clear();
    client.add(null);
    process.add(null);
  }

  void clientOn([String msg = 'connecting to electurm']) => clientAdd(msg);
  bool clientOff([String msg = 'connecting to electurm']) => clientRemove(msg);

  void processOn([String msg = 'running background process']) =>
      processAdd(msg);
  bool processOff([String msg = 'running background process']) =>
      processRemove(msg);

  void addressDerivationOn([String msg = 'deriving new address']) =>
      processAdd(msg);
  bool addressDerivationOff([String msg = 'deriving new address']) =>
      processRemove(msg);

  void encryptionOn([String msg = 'encrypting wallet']) => processAdd(msg);
  bool encryptionOff([String msg = 'encrypting wallet']) => processRemove(msg);

  void createWalletOn([String msg = 'creating wallet']) => processAdd(msg);
  bool createWalletOff([String msg = 'creating wallet']) => processRemove(msg);

  void createTransactionOn([String msg = 'creating transaction']) =>
      processAdd(msg);
  bool createTransactionOff([String msg = 'creating transaction']) =>
      processRemove(msg);
}
