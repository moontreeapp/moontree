part of 'joins.dart';

extension AssetHasOneStatus on Asset {
  Status? get status => pros.statuses.byAsset.getOne(this);
}

extension AssetCanHaveOneParent on Asset {
  Asset? get parent => pros.assets.bySymbol.getOne(parentId ?? '');
}

extension AssetHasOneSecurity on Asset {
  Security? get security =>
      pros.securities.bySymbolSecurityType.getOne(symbol, SecurityType.asset);
}

extension AssetHasOneMetadata on Asset {
  Metadata? get primaryMetadata => [
        pros.metadatas.bySymbolMetadata.getOne(baseSymbol, metadata)
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
      pros.metadatas.bySymbolMetadata.getOne(baseSymbol, metadata)
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
