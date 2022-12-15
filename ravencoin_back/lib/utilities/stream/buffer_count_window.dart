import 'package:rxdart/src/transformers/backpressure/backpressure.dart';

class BufferCountWindowStreamTransformer<T>
    extends BackpressureStreamTransformer<T, List<T>> {
  BufferCountWindowStreamTransformer(
    int count,
    Stream<T> Function(T event) window, [
    int startBufferEvery = 0,
    bool ignoreEmptyWindows = true,
  ]) : super(
          WindowStrategy.firstEventOnly,
          window,
          onWindowEnd: (List<T> queue) => queue,
          startBufferEvery: startBufferEvery,
          closeWindowWhen: (Iterable<T> queue) => queue.length == count,
          ignoreEmptyWindows: ignoreEmptyWindows,
        ) {
    if (count < 1) {
      throw ArgumentError.value(count, 'count');
    }
    if (startBufferEvery < 0) {
      throw ArgumentError.value(startBufferEvery, 'startBufferEvery');
    }
  }
}

extension BufferCountWindowExtensions<T> on Stream<T> {
  /// Buffers the stream and emits the buffer when EITHER:
  /// a) the number of elements reaches `count`, OR
  /// b) the `window` Stream emits
  Stream<List<T>> bufferCountWindow(
    int count,
    Stream<T> window, {
    bool ignoreEmptyWindows = true,
  }) =>
      transform(BufferCountWindowStreamTransformer<T>(
          count, (_) => window, 0, ignoreEmptyWindows));

  /// Buffers the stream and emits the buffer when EITHER:
  /// a) the number of elements reaches `count`, OR
  /// b) a periodic `timeout` occurs
  Stream<List<T>> bufferCountTimeout(
    int count,
    Duration timeout, {
    bool ignoreEmptyWindows = true,
  }) =>
      transform(BufferCountWindowStreamTransformer<T>(
          count, (_) => Stream<T>.periodic(timeout), 0, ignoreEmptyWindows));
}
