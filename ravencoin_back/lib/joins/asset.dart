part of 'joins.dart';

extension AssetHasOneStatus on Asset {
  Status? get status => pros.statuses.primaryIndex.getOneByAsset(this);
}

extension AssetCanHaveOneParent on Asset {
  Asset? get parent => pros.assets.primaryIndex.getOneById(parentId ?? '');
}

extension AssetHasOneSecurity on Asset {
  Security? get security => pros.securities.primaryIndex
      .getOne(symbol, SecurityType.asset, chain, net);
}

extension AssetHasOneMetadata on Asset {
  Metadata? get primaryMetadata => [
        pros.metadatas.primaryIndex.getOne(baseSymbol, metadata, chain, net)
      ].where((md) => md?.parent == null).firstOrNull;
}

extension AssetHasManyMetadata on Asset {
  List<Metadata?> get metadatas => pros.metadatas.bySymbol.getAll(baseSymbol);
}

extension AssetHasOneLogoMetadata on Asset {
  Metadata? get logo {
    var childrenMetadata = pros.metadatas.bySymbol.getAll(baseSymbol);
    for (var child in childrenMetadata) {
      if (child.logo) {
        return child;
      }
    }
    var primaryMetadata = [
      pros.metadatas.primaryIndex.getOne(baseSymbol, metadata, chain, net)
    ].where((md) => md?.parent == null).firstOrNull;
    if (primaryMetadata?.kind == MetadataType.imagePath) {
      return primaryMetadata;
    }
    var nonMasterPrimaryMetadata = pros.metadatas.bySymbol
        .getAll(baseSymbol)
        .where((md) => md.parent == null)
        .firstOrNull;
    if (nonMasterPrimaryMetadata?.kind == MetadataType.imagePath) {
      return nonMasterPrimaryMetadata; // assume parent is logo, could check dims ratio...
    }
    return null;
  }
}
