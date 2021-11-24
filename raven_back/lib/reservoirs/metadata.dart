import 'package:collection/collection.dart';
import 'package:raven/raven.dart';
import 'package:reservoir/reservoir.dart';

part 'metadata.keys.dart';

class MetadataReservoir extends Reservoir<_MetadataIdKey, Metadata> {
  late IndexMultiple<_SymbolKey, Metadata> bySymbol;
  late IndexMultiple<_MetadataKey, Metadata> byMetadata;
  late IndexMultiple<_ParentKey, Metadata> byParent;
  late IndexMultiple<_SymbolMetadataKey, Metadata> bySymbolMetadata;

  MetadataReservoir() : super(_MetadataIdKey()) {
    bySymbol = addIndexMultiple('symbol', _SymbolKey());
    byMetadata = addIndexMultiple('metadata', _MetadataKey());
    byParent = addIndexMultiple('parent', _ParentKey());
    bySymbolMetadata =
        addIndexMultiple('metadataSymbolSecurityType', _SymbolMetadataKey());
  }
}
