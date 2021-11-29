/// listens for new securities and derives and saves logo to disk as image file
/// why does this live here?
/// because raven_mobile manages storage for exports and other files like asset logos.
import 'package:rxdart/rxdart.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/services/ipfs.dart';

class AssetListener {
  void init() {
    streams.asset.added.distinctUnique().listen((Asset asset) {
      assets.save(asset);
      if (asset.isMaster) {
        grabMetadataForMaster(asset);
      } else {
        grabMetadataFor(asset);
      }
    });
  }

  /// get and save content, look for logo, save that too
  Future<void> grabMetadataForMaster(Asset asset) async {
    // master assets should look at the ipfs on the actual unique assets
    // what if we don't hold that asset? we should pull it?
    var unique = assets.bySymbol.getOne(asset.nonMasterSymbol);
    if (unique == null) {
      /// we should pull the asset data for this asset even if we don't own the
      /// asset because we need the ipfshash of it for master asset
      /// so push the nonMasterSymbol into the stream to signal something
      /// to pull it from the client using getMeta function... resulting in...
      //streams.asset.added.add(Asset(
      //    symbol: asset.nonMasterSymbol,
      //    metadata: vout.scriptPubKey.ipfsHash ?? '',
      //    satsInCirculation: value,
      //    precision: vout.scriptPubKey.units ?? 0,
      //    reissuable: vout.scriptPubKey.reissuable == 1,
      //    txId: tx.txid,
      //    position: vout.n,
      //  ));
    } else {
      // if we do own the unique asset the joins will point us to it.
    }
  }

  Future<void> grabMetadataFor(Asset asset) async {
    if (asset.hasIpfs) {
      if (asset.primaryMetadata == null) {
        // pull the contents from ipfs and save a metadata record
        var ipfs = IpfsMiniExplorer(asset.metadata);
        var resp = await ipfs.get();
        metadatas.save(Metadata(
            symbol: asset.symbol,
            metadata: asset.metadata,
            data: resp,
            kind: ipfs.kind,
            parent: null,
            logo: false));
      }
    }
  }
}

class LogoListener {
  void init() {
    streams.metadata.addedJson.listen(
      (Metadata? metadata) => grabChildrenMetadataFor(metadata!),
    );
  }

  /// look for ipfs hashes in this metadata, make children, mark one as logo
  Future<void> grabChildrenMetadataFor(Metadata metadata) async {
    var logoHash = IpfsCall.searchJsonForLogo(jsonString: metadata.data);
    // lets search for anything ipfs
    var hashes = IpfsCall.extractIpfsHashes(metadata.data ?? '');
    for (var hash in hashes) {
      var ipfs = IpfsMiniExplorer(hash);
      var resp = await ipfs.get();
      metadatas.save(Metadata(
        symbol: metadata.symbol,
        metadata: hash,
        data: resp,
        kind: ipfs.kind,
        parent: metadata.metadata,
        logo: logoHash == hash,
      ));
    }
  }
}
