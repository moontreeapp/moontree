import 'dart:async';

import 'package:pedantic/pedantic.dart';

import 'package:raven/reservoir/reservoir.dart';

export 'rx_map_source.dart';
export 'package:raven/reservoir/reservoir.dart';

void enqueueChange(void Function() change) {
  unawaited(Future.microtask(change));
}

Future reservoirChanges(
  Reservoir res,
  void Function() change, [
  int changeCount = 1,
]) async {
  enqueueChange(change);
  await res.changes.take(changeCount).toList();
}
