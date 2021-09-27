import 'dart:async';

abstract class Waiter {
  final List<StreamSubscription> listeners = [];

  Waiter();

  void deinit([dynamic _]) {
    for (var listener in listeners) {
      listener.cancel();
    }
    listeners.clear();
  }
}
