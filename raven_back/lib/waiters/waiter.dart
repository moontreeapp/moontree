import 'dart:async';

import 'package:raven/utils/exceptions.dart' show AlreadyListening;

typedef Listener<T> = void Function(T event);

abstract class Waiter {
  final Map<String, StreamSubscription> listeners = {};

  Waiter();

  void listen<T>(
    String key,
    Stream<T> stream,
    Listener<T> listener, {
    // sometimes we want the following functionality to avoid throwing an error
    bool relax = false,
  }) {
    if (!listeners.keys.contains(key)) {
      listeners[key] = stream.listen(listener);
    } else {
      if (!relax) throw AlreadyListening('$key already listening');
    }
  }

  Future deinit() async {
    for (var listener in listeners.values) {
      await listener.cancel();
    }
    listeners.clear();
  }

  Future deinitKeys(List<String> keys) async {
    for (var listener in keys) {
      await listeners[listener]?.cancel();
      listeners.remove(listener);
    }
  }

  Future deinitKey(String key) async {
    await deinitKeys([key]);
  }
}
