import 'dart:async';

abstract class Waiter {
  final List<StreamSubscription> listeners = [];

  Waiter();

  void deinit() {
    for (var listener in listeners) {
      listener.cancel();
    }
  }
}
