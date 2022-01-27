part of 'joins.dart';

extension MetadataBelongsToAsset on Metadata {
  Asset? get asset => globals.res.assets.bySymbol.getOne(symbol);
}

extension MetadataHasOneParent on Metadata {
  Metadata? get parentMetadata => parent != null
      ? globals.res.metadatas.bySymbolMetadata.getOne(symbol, parent!)
      : null;
}

extension MetadataHasManyChildren on Metadata {
  List<Metadata?> get childrenMetadata =>
      globals.res.metadatas.byParent.getAll(metadata);
}
