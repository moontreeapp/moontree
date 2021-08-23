import 'dart:async';

abstract class Waiter {
  final List<StreamSubscription> listeners = [];

  Waiter();
  void init() {
    throw UnimplementedError('Must override init in a Waiter!');
  }

  void deinit() {
    for (var listener in listeners) {
      listener.cancel();
    }
  }
}
