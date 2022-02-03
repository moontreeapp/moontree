/// unused currently - we may need this soon

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:reservoir/index.dart';
import 'package:rxdart/rxdart.dart';

import '../extensions/stream/partition.dart';

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
  GetKey<String, A> getKeyA,
  GetKey<String, B> getKeyAFromB,
) {
  var rightWaitingForLeft = <String, Set<B>>{};
  var leftMap = <String, A>{};

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
      backlog.add(b);
    });
  });

  var getPair = (B b) => Join(leftMap[getKeyAFromB(b)]!, b);
  var trueJoinStream = streams.trueStream.map(getPair);
  var backlogJoinStream = backlog.stream.map(getPair);
  return trueJoinStream.mergeWith([backlogJoinStream]);
}
