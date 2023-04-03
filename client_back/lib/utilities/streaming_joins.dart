/// unused currently - we may need this soon

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:proclaim/index.dart';
import 'package:rxdart/rxdart.dart';

import 'package:client_back/utilities/stream/partition.dart';

class Join<A, B> with EquatableMixin {
  A left;
  B right;
  Join(this.left, this.right);

  @override
  List<Object?> get props => <Object?>[left, right];
}

Stream<Join<A, B>> streamingLeftJoin<A, B>(
  Stream<A> leftStream,
  Stream<B> rightStream,
  GetKey<String, A> getKeyA,
  GetKey<String, B> getKeyAFromB,
) {
  final Map<String, Set<B>> rightWaitingForLeft = <String, Set<B>>{};
  final Map<String, A> leftMap = <String, A>{};

  final PartitionedStream<B> streams =
      rightStream.partition((B b) => leftMap.containsKey(getKeyAFromB(b)));

  streams.falseStream.listen((B b) {
    final String keyA = getKeyAFromB(b);
    rightWaitingForLeft.putIfAbsent(keyA, () => <B>{});
    rightWaitingForLeft[keyA]!.add(b);
  });

  final StreamController<B> backlog = StreamController<B>();
  leftStream.listen((A a) {
    final String keyA = getKeyA(a);
    leftMap[keyA] = a;
    rightWaitingForLeft[keyA]?.forEach((B b) {
      backlog.add(b);
    });
  });

  Join<A, B> getPair(B b) => Join<A, B>(leftMap[getKeyAFromB(b)] as A, b);
  final Stream<Join<A, B>> trueJoinStream = streams.trueStream.map(getPair);
  final Stream<Join<A, B>> backlogJoinStream = backlog.stream.map(getPair);
  return trueJoinStream.mergeWith(<Stream<Join<A, B>>>[backlogJoinStream]);
}
