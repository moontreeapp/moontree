import 'dart:async';

import 'package:raven/utils/combine.dart';

abstract class Waiter {
  final Map<String, StreamSubscription> listeners = {};

  Waiter();

  Future deinit([String? key, List<String>? keys]) async {
    if (key != null) {
      keys = append(key, keys) as List<String>;
      for (var listener in keys) {
        await listeners[listener]?.cancel();
        listeners.remove(listener);
      }
    } else {
      for (var listener in listeners.values) {
        await listener.cancel();
      }
      listeners.clear();
    }
  }
}
