part of 'metadata.dart';

// primary key

class _MetadataIdKey extends Key<Metadata> {
  @override
  String getKey(Metadata metadata) => metadata.id;
}

extension ByIdMethodsForMetadata on Index<_MetadataIdKey, Metadata> {
  Metadata? getOne(String metadataId) => getByKeyStr(metadataId).firstOrNull;
}

// bySymbolSecurityType
// same as primary key but with two inputs

class _SymbolMetadataKey extends Key<Metadata> {
  @override
  String getKey(Metadata metadata) => metadata.id;
}

extension BySymbolMetadataMethodsForMetadata
    on Index<_SymbolMetadataKey, Metadata> {
  Metadata? getOne(String symbol, String metadata, Chain chain, Net net) =>
      getByKeyStr(Metadata.key(symbol, metadata, chain, net)).firstOrNull;
}

// metadata key

class _MetadataKey extends Key<Metadata> {
  @override
  String getKey(Metadata metadata) => metadata.metadata;
}

extension ByMetadataMethodsForMetadata on Index<_MetadataKey, Metadata> {
  List<Metadata?> getAll(String metadata) => getByKeyStr(metadata);
}

// parent key

class _ParentKey extends Key<Metadata> {
  //todo is this right?
  @override
  String getKey(Metadata metadata) => metadata.parent ?? '';
}

extension ByParentMethodsForMetadata on Index<_ParentKey, Metadata> {
  List<Metadata?> getAll(String metadata) => getByKeyStr(metadata);
}

// bySymbol

class _SymbolKey extends Key<Metadata> {
  @override
  String getKey(Metadata metadata) => metadata.symbol;
}

extension BySymbolMethodsForMetadata on Index<_SymbolKey, Metadata> {
  List<Metadata> getAll(String symbol) => getByKeyStr(symbol);
}

// byMetadataType

class _MetadataTypeKey extends Key<Metadata> {
  @override
  String getKey(Metadata metadata) => metadata.metadataTypeName;
}

extension ByMetadataTypeMethodsForMetadata
    on Index<_MetadataTypeKey, Metadata> {
  List<Metadata> getAll(MetadataType metadataType) =>
      getByKeyStr(metadataType.toString());
}
