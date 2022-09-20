import 'package:collection/collection.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:proclaim/proclaim.dart';

part 'metadata.keys.dart';

class MetadataProclaim extends Proclaim<_MetadataIdKey, Metadata> {
  late IndexMultiple<_SymbolKey, Metadata> bySymbol;
  late IndexMultiple<_MetadataKey, Metadata> byMetadata;
  late IndexMultiple<_ParentKey, Metadata> byParent;
  late IndexMultiple<_SymbolMetadataKey, Metadata> bySymbolMetadata;

  MetadataProclaim() : super(_MetadataIdKey()) {
    bySymbol = addIndexMultiple('symbol', _SymbolKey());
    byMetadata = addIndexMultiple('metadata', _MetadataKey());
    byParent = addIndexMultiple('parent', _ParentKey());
    bySymbolMetadata =
        addIndexMultiple('metadataSymbolSecurityType', _SymbolMetadataKey());
  }
}
