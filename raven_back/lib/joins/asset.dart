part of 'joins.dart';

extension AssetHasOneSecurity on Asset {
  Security? get security => globals.securities.bySymbolSecurityType
      .getOne(symbol, SecurityType.RavenAsset);
}

extension AssetHasOneMetadata on Asset {
  Metadata? get primaryMetadata => [
        globals.metadatas.bySymbolMetadata.getOne(nonMasterSymbol, metadata)
      ].where((md) => md?.parent == null).firstOrNull;
}

extension AssetHasManyMetadata on Asset {
  List<Metadata?> get metadatas =>
      globals.metadatas.bySymbol.getAll(nonMasterSymbol);
}

extension AssetHasOneLogoMetadata on Asset {
  Metadata? get logo {
    var childrenMetadata = globals.metadatas.bySymbol.getAll(nonMasterSymbol);
    for (var child in childrenMetadata) {
      if (child.logo) {
        return child;
      }
    }
    var primaryMetadata = [
      globals.metadatas.bySymbolMetadata.getOne(nonMasterSymbol, metadata)
    ].where((md) => md?.parent == null).firstOrNull;
    if (primaryMetadata?.kind == MetadataType.ImagePath) {
      return primaryMetadata;
    }
    var nonMasterPrimaryMetadata = globals.metadatas.bySymbol
        .getAll(nonMasterSymbol)
        .where((md) => md.parent == null)
        .firstOrNull;
    if (nonMasterPrimaryMetadata?.kind == MetadataType.ImagePath) {
      return nonMasterPrimaryMetadata; // assume parent is logo, could check dims ratio...
    }
  }
}
