import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';

import 'partition_ext.dart';

class Join<A, B> with EquatableMixin {
  A left;
  B right;
  Join(this.left, this.right);

  @override
  List<Object?> get props => [left, right];
}

Stream<Join<A, B>> streamingLeftJoin<A, B>(
  Stream<A> leftStream,
  Stream<B> rightStream,
  int Function(A a) getKeyA,
  int Function(B b) getKeyAFromB,
) {
  var rightWaitingForLeft = <int, Set<B>>{};
  var leftMap = <int, A>{};

  var streams =
      rightStream.partition((B b) => leftMap.containsKey(getKeyAFromB(b)));

  streams.falseStream.listen((B b) {
    var keyA = getKeyAFromB(b);
    rightWaitingForLeft.putIfAbsent(keyA, () => {});
    rightWaitingForLeft[keyA]!.add(b);
  });

  var backlog = StreamController<B>();
  leftStream.listen((A a) {
    var keyA = getKeyA(a);
    leftMap[keyA] = a;
    rightWaitingForLeft[keyA]?.forEach((B b) {
      backlog.sink.add(b);
    });
  });

  var getPair = (B b) => Join(leftMap[getKeyAFromB(b)]!, b);
  var trueJoinStream = streams.trueStream.map(getPair);
  var backlogJoinStream = backlog.stream.map(getPair);
  return trueJoinStream.mergeWith([backlogJoinStream]);
}
