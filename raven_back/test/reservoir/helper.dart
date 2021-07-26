import 'dart:async';

import 'package:pedantic/pedantic.dart';

import 'package:raven/subjects/reservoir.dart';

export 'rx_map.dart';
export 'rx_map_source.dart';
export 'package:raven/subjects/reservoir.dart';

void enqueueChange(void Function() change) {
  unawaited(Future.microtask(change));
}

Future asyncChange(Reservoir res, void Function() change) async {
  enqueueChange(change);
  await res.changes.first;
}
