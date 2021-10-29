// dart test test/sandbox/behavior_stream.dart
import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('forEach is not isolated', () async {
    var data = [1, 2, 3];
    var stream = BehaviorSubject<int>();
    stream.listen((item) => print(item));
    await stream.addStream(Stream.fromIterable(data));
    stream.sink.add(4);
    data.add(5); // not printed - to achieve this kind of pattern you'd have to
    // use something like using the ObservableList below, created as an example.
  });
}

/*
class ObservableList<T> {
  final _list = <T>[];
  final _itemAddedStreamController = StreamController<T>();
  final _listStreamController = StreamController<List<T>>();

  Stream get itemAddedStream => _itemAddedStreamController.stream;
  Stream get listStream => _listStreamController.stream;

  void add(T value) {
    _list.add(value);
    _itemAddedStreamController.add(value);
    _listStreamController.add(_list);
  }

  void dispose() {
    _listStreamController.close();
    _itemAddedStreamController.close();
  }
}

final observableList = ObservableList<int>();
observableList.itemAddedStream.listen((value) => print(value));
observableList.add(1);
observableList.add(2);
observableList.add(3);
*/