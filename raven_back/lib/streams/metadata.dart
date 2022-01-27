import 'package:rxdart/rxdart.dart';

import 'package:raven_back/raven_back.dart';

class MetadataStreams {
  final addedJson = addedJson$;
}

final BehaviorSubject<Metadata?> addedJson$ = BehaviorSubject.seeded(null)
  ..addStream(res.metadatas.changes
      .where((change) => change is Added)
      .map((change) => change.data)
      .where((data) => data.kind == MetadataType.JsonString));
