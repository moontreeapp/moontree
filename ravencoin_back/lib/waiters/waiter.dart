import 'dart:async';

import 'package:moontree_utils/moontree_utils.dart';

typedef Listener<T> = void Function(T event);

abstract class Waiter {
  Waiter();

  final Map<String, StreamSubscription<dynamic>> listeners =
      <String, StreamSubscription<dynamic>>{};

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
    for (final StreamSubscription<dynamic> listener in listeners.values) {
      await listener.cancel();
    }
    listeners.clear();
  }

  Future<void> deinitKeys(List<String> keys) async {
    for (final String listener in keys) {
      print('removing $listener');
      await listeners[listener]?.cancel();
      listeners.remove(listener);
    }
  }

  Future<void> deinitKey(String key) async => deinitKeys(<String>[key]);
}
