import 'dart:async';
import 'package:moontree_utils/src/exceptions.dart' show AlreadyListening;

typedef Listener<T> = void Function(T event);
typedef Check<T> = bool Function(T event);

abstract class Trigger {
  Trigger();
  final Map<String, StreamSubscription<dynamic>> listeners =
      <String, StreamSubscription<dynamic>>{};

  Future<void> when<T>({
    required Stream<T> thereIsA,
    Check<T>? andIf,
    required Listener<T> doThis,
    String? key,
    bool autoDeinit = false,
  }) async {
    key ??= determineKey(thereIsA);
    if (autoDeinit) {
      await deinitKey(key);
    }
    if (!listeners.keys.contains(key)) {
      listeners[key] = thereIsA
          .listen(andIf == null ? doThis : (T v) => andIf(v) ? doThis : () {});
    } else {
      throw AlreadyListening('$key already listening');
    }
  }

  String determineKey<T>(Stream<T> stream) =>
      () {
        /// automatically use name from ReadableIdentifierExtension
        try {
          return (stream as dynamic).name;
        } on NoSuchMethodError {
          return null;
        } catch (e) {
          print('Unexpected Error: $e');
        }
        return null;
      }() ??
      stream.hashCode.toString();

  Future<void> deinit() async {
    for (final StreamSubscription<dynamic> listener in listeners.values) {
      await listener.cancel();
    }
    listeners.clear();
  }

  Future<void> deinitKeys(List<String> keys) async {
    for (final String listener in keys) {
      await listeners[listener]?.cancel();
      listeners.remove(listener);
    }
  }

  Future<void> deinitKey(String key) async => deinitKeys(<String>[key]);
}
