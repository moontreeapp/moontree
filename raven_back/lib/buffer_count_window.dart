import 'package:rxdart/src/transformers/backpressure/backpressure.dart';

class BufferCountWindowStreamTransformer<T>
    extends BackpressureStreamTransformer<T, List<T>> {
  BufferCountWindowStreamTransformer(int count, Stream Function(T event) window,
      [int startBufferEvery = 0])
      : super(WindowStrategy.firstEventOnly, window,
            onWindowEnd: (List<T> queue) => queue,
            startBufferEvery: startBufferEvery,
            closeWindowWhen: (Iterable<T> queue) => queue.length == count,
            ignoreEmptyWindows: true) {
    if (count < 1) throw ArgumentError.value(count, 'count');
    if (startBufferEvery < 0) {
      throw ArgumentError.value(startBufferEvery, 'startBufferEvery');
    }
  }
}

extension BufferCountWindowExtensions<T> on Stream<T> {
  Stream<List<T>> bufferCountWindow(int count, Stream window) =>
      transform(BufferCountWindowStreamTransformer(count, (_) => window));

  Stream<List<T>> bufferCountTimeout(int count, Duration timeout) {
    return bufferCountWindow(count, Stream.periodic(timeout));
  }
}
