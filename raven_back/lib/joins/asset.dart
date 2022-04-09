part of 'joins.dart';

extension AssetHasOneStatus on Asset {
  Status? get status => res.statuses.byAsset.getOne(this);
}

extension AssetCanHaveOneParent on Asset {
  Asset? get parent => res.assets.bySymbol.getOne(parentId ?? '');
}

extension AssetHasOneSecurity on Asset {
  Security? get security => res.securities.bySymbolSecurityType
      .getOne(symbol, SecurityType.RavenAsset);
}

extension AssetHasOneMetadata on Asset {
  Metadata? get primaryMetadata => [
        res.metadatas.bySymbolMetadata.getOne(baseSymbol, metadata)
      ].where((md) => md?.parent == null).firstOrNull;
}

extension AssetHasManyMetadata on Asset {
  List<Metadata?> get metadatas => res.metadatas.bySymbol.getAll(baseSymbol);
}

extension AssetHasOneLogoMetadata on Asset {
  Metadata? get logo {
    var childrenMetadata = res.metadatas.bySymbol.getAll(baseSymbol);
    for (var child in childrenMetadata) {
      if (child.logo) {
        return child;
      }
    }
    var primaryMetadata = [
      res.metadatas.bySymbolMetadata.getOne(baseSymbol, metadata)
    ].where((md) => md?.parent == null).firstOrNull;
    if (primaryMetadata?.kind == MetadataType.ImagePath) {
      return primaryMetadata;
    }
    var nonMasterPrimaryMetadata = res.metadatas.bySymbol
        .getAll(baseSymbol)
        .where((md) => md.parent == null)
        .firstOrNull;
    if (nonMasterPrimaryMetadata?.kind == MetadataType.ImagePath) {
      return nonMasterPrimaryMetadata; // assume parent is logo, could check dims ratio...
    }
    return null;
  }
}
