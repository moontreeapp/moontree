import 'dart:async';

import 'package:raven_back/utilities/exceptions.dart' show AlreadyListening;

typedef Listener<T> = void Function(T event);

abstract class Waiter {
  final Map<String, StreamSubscription> listeners = {};

  Waiter();

  Future<void> listen<T>(
    String key,
    Stream<T> stream,
    Listener<T> listener, {
    bool autoDeinit = false,
  }) async {
    if (autoDeinit) {
      await deinitKey(key);
    }
    if (!listeners.keys.contains(key)) {
      listeners[key] = stream.listen(listener);
    } else {
      throw AlreadyListening('$key already listening');
    }
  }

  Future<void> deinit() async {
    for (var listener in listeners.values) {
      await listener.cancel();
    }
    listeners.clear();
  }

  Future<void> deinitKeys(List<String> keys) async {
    for (var listener in keys) {
      print('removing $listener');
      await listeners[listener]?.cancel();
      listeners.remove(listener);
    }
  }

  Future<void> deinitKey(String key) async => await deinitKeys([key]);
}
