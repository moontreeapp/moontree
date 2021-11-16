/// listens for new securities and derives and saves logo to disk as image file
/// why does this live here?
/// because raven_mobile manages storage for exports and other files like asset logos.
import 'package:raven/raven.dart';
import 'package:raven_mobile/services/ipfs.dart';

class LogoListener {
  void init() {
    securities.changes.listen((Change<Security> change) {
      change.when(loaded: (loaded) {
        // verify logo present?
      }, added: (added) async {
        var security = added.data;
        // if the metadata is a valid ipfs hash and no logo pull attempt has been made:
        if (security.hasIpfs && security.ipfsLogo == null) {
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
            ipfsLogo = meta.icon;
          } // if one is not found... save the fact that we looked so we don't again.
          securities.save(Security.fromSecurity(security, ipfsLogo: ipfsLogo));
        }
      }, updated: (updated) {
        // repull logo?
      }, removed: (removed) {
        // clean up logo image?
      });
    });
  }
}
