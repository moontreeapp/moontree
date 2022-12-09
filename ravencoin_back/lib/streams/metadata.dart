import 'package:rxdart/rxdart.dart';
import 'package:moontree_utils/moontree_utils.dart'
    show ReadableIdentifierExtension;
import 'package:ravencoin_back/ravencoin_back.dart';

class MetadataStreams {
  final BehaviorSubject<Metadata?> addedJson =
      BehaviorSubject<Metadata?>.seeded(null)
        ..addStream(pros.metadatas.changes
            .where((Change<Metadata> change) => change is Added)
            .map((Change<Metadata> change) => change.record)
            .where((Metadata data) => data.kind == MetadataType.jsonString))
        ..name = 'metadata.addedJson';
}
