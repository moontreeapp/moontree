part of 'joins.dart';

extension MetadataBelongsToAsset on Metadata {
  Asset? get asset => res.assets.bySymbol.getOne(symbol);
}

extension MetadataHasOneParent on Metadata {
  Metadata? get parentMetadata => parent != null
      ? res.metadatas.bySymbolMetadata.getOne(symbol, parent!)
      : null;
}

extension MetadataHasManyChildren on Metadata {
  List<Metadata?> get childrenMetadata =>
      res.metadatas.byParent.getAll(metadata);
}
