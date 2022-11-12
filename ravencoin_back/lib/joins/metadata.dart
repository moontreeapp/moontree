part of 'joins.dart';

extension MetadataBelongsToAsset on Metadata {
  Asset? get asset => pros.assets.primaryIndex.getOne(symbol, chain, net);
}

extension MetadataHasOneParent on Metadata {
  Metadata? get parentMetadata => parent != null
      ? pros.metadatas.primaryIndex.getOne(symbol, parent!, chain, net)
      : null;
}

extension MetadataHasManyChildren on Metadata {
  List<Metadata?> get childrenMetadata =>
      pros.metadatas.byParent.getAll(metadata);
}
