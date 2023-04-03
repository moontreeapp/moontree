import 'package:collection/collection.dart';
import 'package:proclaim/proclaim.dart';
import 'package:client_back/client_back.dart';

part 'metadata.keys.dart';

class MetadataProclaim extends Proclaim<_IdKey, Metadata> {
  late IndexMultiple<_SymbolKey, Metadata> bySymbol;
  late IndexMultiple<_MetadataKey, Metadata> byMetadata;
  late IndexMultiple<_ParentKey, Metadata> byParent;

  MetadataProclaim() : super(_IdKey()) {
    bySymbol = addIndexMultiple('symbol', _SymbolKey());
    byMetadata = addIndexMultiple('metadata', _MetadataKey());
    byParent = addIndexMultiple('parent', _ParentKey());
  }
}
