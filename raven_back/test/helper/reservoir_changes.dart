import 'dart:async';
import 'package:pedantic/pedantic.dart';
import 'package:reservoir/reservoir.dart';

void enqueueChange(void Function() change) {
  unawaited(Future.microtask(change));
}

Future reservoirChanges(
  Reservoir res,
  void Function() change, [
  int changeCount = 1,
]) async {
  enqueueChange(change);
  return await res.changes.take(changeCount).toList();
}
