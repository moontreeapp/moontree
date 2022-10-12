part of 'joins.dart';

extension MetadataBelongsToAsset on Metadata {
  Asset? get asset => pros.assets.bySymbol.getOne(symbol);
}

extension MetadataHasOneParent on Metadata {
  Metadata? get parentMetadata => parent != null
      ? pros.metadatas.bySymbolMetadata.getOne(symbol, parent!, chain, net)
      : null;
}

extension MetadataHasManyChildren on Metadata {
  List<Metadata?> get childrenMetadata =>
      pros.metadatas.byParent.getAll(metadata);
}
