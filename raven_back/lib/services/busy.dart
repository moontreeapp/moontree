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
  final BehaviorSubject client = BehaviorSubject<String?>();
  final BehaviorSubject process = BehaviorSubject<String?>();
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

  void clientOn([String msg = 'Connecting to Electurm']) => clientAdd(msg);
  bool clientOff([String msg = 'Connecting to Electurm']) => clientRemove(msg);

  void addressDerivationOn([String msg = 'Deriving New Address']) =>
      processAdd(msg);
  bool addressDerivationOff([String msg = 'Deriving New Address']) =>
      processRemove(msg);

  void encryptionOn([String msg = 'Encrypting Wallet']) => processAdd(msg);
  bool encryptionOff([String msg = 'Encrypting Wallet']) => processRemove(msg);

  void createWalletOn([String msg = 'Creating Wallet']) => processAdd(msg);
  bool createWalletOff([String msg = 'Creating Wallet']) => processRemove(msg);

  void createTransactionOn([String msg = 'Creating Transaction']) =>
      processAdd(msg);
  bool createTransactionOff([String msg = 'Creating Transaction']) =>
      processRemove(msg);
}
