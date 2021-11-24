part of 'joins.dart';

extension AssetHasOneSecurity on Asset {
  Security? get security => globals.securities.bySymbolSecurityType
      .getOne(symbol, SecurityType.RavenAsset);
}

extension AssetHasOneMetadata on Asset {
  Metadata? get primaryMetadata => [
        globals.metadata.bySymbolMetadata.getOne(symbol, metadata)
      ].where((md) => md?.parent == null).firstOrNull;
}

extension AssetHasManyMetadata on Asset {
  List<Metadata?> get metadatas => globals.metadata.bySymbol.getAll(symbol);
}

extension AssetHasOneLogoMetadata on Asset {
  Metadata? get logo {
    var primaryMetadata = [
      globals.metadata.bySymbolMetadata.getOne(symbol, metadata)
    ].where((md) => md?.parent == null).firstOrNull;
    var childrenMetadata = globals.metadata.bySymbol.getAll(symbol);
    Metadata? logoChild;
    for (var child in childrenMetadata) {
      if (child.logo) {
        logoChild = child;
        break;
      }
    }
    if (logoChild != null) {
      return logoChild;
    }
    if (logoChild == null && primaryMetadata?.kind == MetadataType.ImagePath) {
      return primaryMetadata;
    }
  }
}
