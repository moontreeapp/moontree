import 'dart:async';

abstract class Waiter {
  final Map<String, StreamSubscription> listeners = {};

  Waiter();

  Future deinit() async {
    for (var listener in listeners.values) {
      await listener.cancel();
    }
    listeners.clear();
  }
}
