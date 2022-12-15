// ignore_for_file: avoid_classes_with_only_static_members

import 'package:rxdart/rxdart.dart';

class PartitionedStream<T> {
  Stream<T> trueStream;
  Stream<T> falseStream;
  PartitionedStream(this.trueStream, this.falseStream);
}

// see https://github.com/ReactiveX/rxdart/issues/382#issuecomment-567823906
extension PartitionExt<T> on Stream<T> {
  /// Splits the this Observable into two, one with values that satisfy a
  /// predicate, and another with values that don't satisfy the predicate.
  PartitionedStream<T> partition(bool Function(T event) predicate) =>
      ParititonUtil.parititon(this, predicate);
}

class ParititonUtil {
  /// Splits the [source] Observable into two, one with values that satisfy a
  /// [predicate], and another with values that don't satisfy the [predicate].
  static PartitionedStream<T> parititon<T>(
    Stream<T> source,
    bool Function(T event) predicate,
  ) {
    bool Function(T) not(bool Function(T event) test) =>
        (T event) => !test(event);

    final Stream<T> stream = source.isBroadcast ? source : source.share();

    return PartitionedStream<T>(
      stream.where(predicate),
      stream.where(not(predicate)),
    );
  }
}
