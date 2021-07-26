import 'dart:async';

import 'package:quiver/collection.dart';
import 'package:raven/subjects/change.dart';

class RxMap<K, V> extends DelegatingMap<K, V> {
  final StreamController<Change> _subject = StreamController.broadcast();

  Stream<Change> get stream => _subject.stream;

  @override
  final delegate = {};

  @override
  void operator []=(K key, V value) {
    if (!delegate.containsKey(key)) {
      delegate[key] = value;
      _subject.sink.add(Added(key as Object, value));
    } else {
      delegate[key] = value;
      _subject.sink.add(Updated(key as Object, value));
    }
  }

  @override
  V? remove(Object? key) {
    var removed;
    if (delegate.containsKey(key)) {
      removed = delegate.remove(key);
      _subject.sink.add(Removed(key as Object));
    }
    return removed;
  }
}
