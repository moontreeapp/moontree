import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/records/records.dart';
import 'package:raven_front/services/storage.dart';
import 'package:raven_front/utils/identicon.dart';

class IconComponents {
  IconComponents();

  Icon get back => Icon(Icons.chevron_left_rounded, color: Colors.white);
  Icon get close => Icon(Icons.close, color: Colors.white);

  Widget income(BuildContext context) =>
      Image.asset('assets/icons/receive/receive_green.png');

  Widget out(BuildContext context) =>
      Image.asset('assets/icons/send/send_red.png');

  Icon importDisabled(BuildContext context) =>
      Icon(Icons.vpn_key_rounded, color: Theme.of(context).disabledColor);

  Icon get import => Icon(Icons.vpn_key_rounded, color: Color(0xDE000000));

  Icon get export => Icon(Icons.save);

  Image get assetMasterImage => Image.asset('assets/masterbag_transparent.png');
  Image get assetRegularImage => Image.asset('assets/assetbag_transparent.png');

  Widget assetAvatar(String asset, {double? height, double? width}) {
    if (asset.toUpperCase() == 'RVN') {
      return _assetAvatarRVN(height: height, width: width);
    }
    var ret = _assetAvatarSecurity(asset, height: height, width: width);
    if (ret != null) {
      return ret;
    }
    return _assetAvatarGeneratedIdenticon(asset, height: height, width: width);
  }

  Widget _assetAvatarRVN({double? height, double? width}) => Image.asset(
        'assets/rvn.png',
        height: height,
        width: width,
      );

  /// return custom logo (presumably previously downloaded from ipfs) or null
  Widget? _assetAvatarSecurity(String symbol, {double? height, double? width}) {
    var security = res.securities.bySymbolSecurityType
        .getOne(symbol, SecurityType.RavenAsset);
    if (security != null &&
        !([null, '']).contains(security.asset?.logo?.data)) {
      try {
        return Image.file(
            AssetLogos().readImageFileNow(security.asset?.logo?.data ?? ''),
            height: height,
            width: width);
      } catch (e) {
        print(
            'unable to open image asset file for ${security.asset?.logo?.data}: $e');
      }
    }
  }

  Widget _assetAvatarGeneratedIdenticon(
    String asset, {
    double? height,
    double? width,
  }) {
    var imageDetails = Identicon().generate(asset);
    var indicator = generateIndicator(name: asset, imageDetails: imageDetails);
    return Stack(alignment: Alignment.bottomRight, children: [
      Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                width: 2,
                color: Color.fromARGB(
                  255,
                  imageDetails.foreground[0],
                  imageDetails.foreground[1],
                  imageDetails.foreground[2],
                ))),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100.0),
          child: Center(
            child: Container(
              child: Image.memory(Uint8List.fromList(imageDetails.image)),
            ),
          ),
        ),
      ),
      if (indicator != null) indicator,
    ]);
  }

  Widget? generateIndicator({
    required String name,
    required ImageDetails imageDetails,
  }) {
    if (name.startsWith('#')) {
      return Icon(Icons.ac_unit,
          color: getIndicatorColor(imageDetails.background));
    }
    if (name.startsWith('\$')) {
      return Icon(MdiIcons.lock,
          color: getIndicatorColor(imageDetails.background));
    }
    if (name.endsWith('!')) {
      //if (name.startsWith('M')) {
      return Container(
          height: 20,
          width: 20,
          decoration: BoxDecoration(
              color: Color.fromARGB(
                255,
                imageDetails.background[0],
                imageDetails.background[1],
                imageDetails.background[2],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                  width: 2,
                  color: Color.fromARGB(
                    255,
                    imageDetails.foreground[0],
                    imageDetails.foreground[1],
                    imageDetails.foreground[2],
                  ))),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: Center(
                  child: Container(
                      child: Icon(MdiIcons.crown,
                          size: 14,
                          color:
                              getIndicatorColor(imageDetails.background))))));
    }
    return null;
  }

  Color getIndicatorColor(List<int> backgroundColor) {
    return backgroundColor.sum() >= 128 ? Colors.black : Colors.white;
  }

/*
import 'package:raven_front/widgets/other/circle_gradient.dart';
  /// no logo? no problem, we'll make one...
  /// Remove the `!` when calculating hash, so each master asset
  /// matches its corresponding regular asset autogenerated colors
  Widget _assetAvatarGenerated(String asset, {double? height, double? width}) {
    var i = fnv1a_64(asset.codeUnits);
    if (asset.endsWith('!')) {
      i = fnv1a_64(asset.substring(0, asset.length - 1).codeUnits);
      return Container(
          child: moneybag(gradients[i % gradients.length], assetMasterImage),
          height: height,
          width: width);
    }
    return Container(
        child: moneybag(gradients[i % gradients.length], assetRegularImage),
        height: height,
        width: width);
  }
    // replace with the new thing...
  Widget moneybag(ColorPair background, Image foreground) =>
      Stack(children: [PopCircle(colorPair: background), foreground]);

*/
/*
  import 'package:raven_front/services/identicon.dart';
  /// no logo? no problem, we'll make one...
  /// Remove the `!` when calculating hash, so each master asset
  /// matches its corresponding regular asset autogenerated colors.
  /// Also, look to see if we've saved it before, otherwise go grab it.
  /// lastly, if we can't connect to the api, return null.
  Widget? _assetAvatarIdenticon(String asset, {double? height, double? width}) {
    var assetName =
        asset.endsWith('!') ? asset.substring(0, asset.length - 1) : asset;
    try {
      return SvgPicture.file(
          AssetLogos()
              .readImageFileNow('${settings.localPath}/images/$assetName.svg'),
          height: height,
          width: width);
    } catch (e) {
      var identicon = Identicon(
        name: '$assetName.svg',
        size: 40,
        radius: 50,
        background: '23F57D00',
      );
      identicon.get().then((value) => (AssetLogos()
          .writeLogo(filename: '$assetName.svg', bytes: value.bytes)));
      return SvgPicture.network(identicon.url, height: height, width: width);
    }
  }
*/
/*
  import 'package:jdenticon_dart/jdenticon_dart.dart';
  Widget _assetJdenticon(String asset, {double? height, double? width}) {
    //return Stack(children: [
    ///return ClipRRect(
    ///    borderRadius: BorderRadius.circular(100.0),
    ///    child:
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              width: 2,
              color:
                  asset.endsWith('!') ? Color(0xFFFF9900) : Color(0xFF5C6BC0))),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100.0),
        child: Center(
          child: SvgPicture.string(
            Jdenticon.toSvg(
                asset.endsWith('!')
                    ? asset.substring(0, asset.length - 1)
                    : asset,
                padding: 0,
                colorSaturation: 1,
                grayscaleSaturation: 1,
                backColor: '#5C6BC0FF',
                hues: [36]),
            height: height,
            width: width,
          ),
        ),
      ),
    );
    //  ),
    //  SvgPicture.asset(
    //    'assets/icons/extras/transparent_circle_white.svg',
    //    height: height,
    //    width: width,
    //  ),
    //]);
  }
*/

  CircleAvatar appAvatar() =>
      CircleAvatar(backgroundImage: AssetImage('assets/rvn256.png'));

  CircleAvatar accountAvatar() =>
      CircleAvatar(backgroundImage: AssetImage('assets/rvn256.png'));

  CircleAvatar walletAvatar(Wallet wallet) => wallet is LeaderWallet
      ? CircleAvatar(backgroundImage: AssetImage('assets/rvn256.png'))
      : CircleAvatar(backgroundImage: AssetImage('assets/rvn256.png'));
}
