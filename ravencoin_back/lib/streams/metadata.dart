import 'package:rxdart/rxdart.dart';

import 'package:ravencoin_back/ravencoin_back.dart';

class MetadataStreams {
  final addedJson = addedJson$;
}

final BehaviorSubject<Metadata?> addedJson$ = BehaviorSubject.seeded(null)
  ..addStream(pros.metadatas.changes
      .where((change) => change is Added)
      .map((change) => change.data)
      .where((data) => data.kind == MetadataType.JsonString));
