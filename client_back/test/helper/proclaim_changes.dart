import 'dart:async';
import 'package:pedantic/pedantic.dart';
import 'package:proclaim/proclaim.dart';

void enqueueChange(void Function() change) {
  unawaited(Future.microtask(change));
}

Future proclaimChanges(
  Proclaim res,
  void Function() change, [
  int changeCount = 1,
]) async {
  enqueueChange(change);
  return await res.changes.take(changeCount).toList();
}
