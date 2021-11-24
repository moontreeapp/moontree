part of 'joins.dart';

extension MetadataBelongsToAsset on Metadata {
  Asset? get asset => globals.assets.bySymbol.getOne(symbol);
}

extension MetadataHasOneParent on Metadata {
  Metadata? get parentMetadata => parent != null
      ? globals.metadata.bySymbolMetadata.getOne(symbol, parent!)
      : null;
}

extension MetadataHasManyChildren on Metadata {
  List<Metadata?> get childrenMetadata =>
      globals.metadata.byParent.getAll(metadata);
}