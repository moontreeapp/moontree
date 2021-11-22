/// listens for new securities and derives and saves logo to disk as image file
/// why does this live here?
/// because raven_mobile manages storage for exports and other files like asset logos.
import 'package:raven/raven.dart';
import 'package:raven_mobile/services/ipfs.dart';

class LogoListener {
  Map<String, String> logos = {};

  void init() {
    securities.changes.listen((Change<Security> change) {
      change.when(loaded: (loaded) {
        // verify logo present?
      }, added: (added) {
        manageSecurity(added.data);
      }, updated: (updated) {
        manageSecurity(updated.data);
      }, removed: (removed) {
        // clean up logo image?
      });
    });
  }

  // handle master vs unique asset
  Future<void> manageSecurity(Security security) async {
    if (security.isMaster) {
      // master assets should look at the ipfs on the actual unique assets.
      if (logos.keys.contains(security.nonMasterSymbol)) {
        securities.save(Security.fromSecurity(security,
            ipfsLogo: logos[security.nonMasterSymbol]));
      } else {
        var uniqueAsset = securities.bySymbolSecurityType
            .getOne(security.nonMasterSymbol, SecurityType.RavenAsset);
        // in theory this should never get triggered because if we have this, then it already should be in the logos.keys... but...
        // if we do find it, get the logo for it and set it to both
        if (uniqueAsset != null) {
          getAndSaveLogo(uniqueAsset, masterSecurity: security);
        }
      }
    } else {
      getAndSaveLogo(security);
    }
  }

  Future<void> getAndSaveLogo(
    Security security, {
    Security? masterSecurity,
  }) async {
    var ipfsLogo = security.ipfsLogo;
    if (security.hasIpfs && ipfsLogo == null) {
      if (logos.keys.contains(security.symbol)) {
        ipfsLogo = logos[security.symbol];
      } else {
        ipfsLogo = await pullLogo(security);
        logos[security.symbol] = ipfsLogo;
      }
      securities.save(Security.fromSecurity(security, ipfsLogo: ipfsLogo));
    }
    if (masterSecurity != null) {
      securities
          .save(Security.fromSecurity(masterSecurity, ipfsLogo: ipfsLogo));
    }
  }

  Future<String> pullLogo(Security security, {String? overrideSymbol}) async {
    // pull the ipfs data, try to interpret it to derive an ipfslogo from it
    var meta = MetadataGrabber(security.metadata);
    var ipfsLogo = '';
    if (await meta.get()) {
      // if one is found... return true so we know you...
      //   download the file and
      //     save it to disk with the ipfsHash (for the logo)
      //     as the name of the file
      //   made the ipfsLogo hash available to us so we can
      //     update the record.
      ipfsLogo = meta.logo!;
    } // if one is not found... save the fact that we looked so we don't again.
    return ipfsLogo;
  }
}
