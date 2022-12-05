import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/services/storage.dart';
import 'package:ravencoin_front/theme/theme.dart';
import 'package:ravencoin_front/utils/alphacon.dart';
import 'package:ravencoin_front/widgets/assets/assets.dart' as assets;
//import 'package:ravencoin_front/utils/identicon.dart';
import 'package:equatable/equatable.dart';

class IconComponents {
  Map<IconCacheKey, Widget> cache = {};

  Icon get back => Icon(Icons.chevron_left_rounded, color: Colors.white);

  Icon get close => Icon(Icons.close, color: Colors.white);

  Widget income(BuildContext context) =>
      Image.asset('assets/icons/receive/receive_green.png');

  Widget out(BuildContext context, {Color? color}) => Image.asset(
        'assets/icons/send/send_red.png',
        color: color,
      );
  Widget fee(BuildContext context, {Color? color}) => Image.asset(
        'assets/icons/send/send_black.png',
        color: AppColors.black38,
      );

  Icon importDisabled(BuildContext context) =>
      Icon(Icons.vpn_key_rounded, color: Theme.of(context).disabledColor);

  Icon get import => Icon(Icons.vpn_key_rounded, color: AppColors.black87);

  Icon get export => Icon(Icons.save);

  Icon get preview => Icon(MdiIcons.checkboxMarkedCircleOutline);

  Icon get disabledPreview =>
      Icon(MdiIcons.checkboxMarkedCircleOutline, color: AppColors.disabled);

  Image get assetMasterImage => Image.asset('assets/masterbag_transparent.png');
  Image get assetRegularImage => Image.asset('assets/assetbag_transparent.png');

  Widget assetAvatar(
    String asset, {
    double? size,
    double? height,
    double? width,
    ImageDetails? imageDetails,
    Color? foreground,
    Color? background,
    bool circled = true,
    Net? net,
  }) {
    height = height ?? size;
    width = width ?? size;
    if (asset.toUpperCase() == pros.securities.RVN.symbol) {
      if (net == Net.test) {
        return ColorFiltered(
            colorFilter: assets.filters.greyscale,
            child: assets.icons
                .ravencoinTest(height: height, width: width, circled: circled)
            //_assetAvatarRVN(height: height, width: width)
            );
      }
      //return _assetAvatarRVN(height: height, width: width);
      return assets.icons
          .ravencoin(height: height, width: width, circled: circled);
    }
    if (asset.toUpperCase() == pros.securities.EVR.symbol) {
      if (net == Net.test) {
        return assets.icons.evrmoreTest(
            height: height ?? 24, width: width ?? 24, circled: circled);
      }
      return assets.icons
          .evrmore(height: height ?? 24, width: width ?? 24, circled: circled);
    }

    /// example of custom image:
    //if (asset.toUpperCase().startsWith('MOONTREE')) {
    //  imageDetails = imageDetails ??
    //      getImageDetailsAlphacon(
    //        asset,
    //        foreground,
    //        background,
    //      );
    //  var indicator =
    //      generateIndicator(name: asset, imageDetails: imageDetails);
    //  return Stack(alignment: Alignment.bottomRight, children: <Widget>[
    //    _assetAvatarMoontree(height: height, width: width),
    //    if (indicator != null) indicator,
    //  ]);
    //}

    /// works but never returns anything because we have no custom images...
    /// so removing for now to save compute cycles
    //var ret = _assetAvatarSecurity(asset, height: height, width: width);
    //if (ret != null) {
    //  return ret;
    //}

    return assetFromCacheOrGenerate(asset: asset, height: height, width: width);
  }

  Widget _assetAvatarRVN({double? height, double? width}) => Image.asset(
        'assets/rvn.png',
        height: height,
        width: width,
      );

  Widget _assetAvatarEVR({double? height, double? width}) =>
      assets.icons.evrmore(height: 24, width: 24, circled: true);

  Widget _assetAvatarMoontree({double? height, double? width}) => Image.asset(
        'assets/logo/moontree.png',
        height: height,
        width: width,
      );

  /// return custom logo (presumably previously downloaded from ipfs) or null
  Widget? _assetAvatarSecurity(String symbol, {double? height, double? width}) {
    var security = pros.securities.primaryIndex
        .getOne(symbol, pros.settings.chain, pros.settings.net);
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
    return null;
  }

  Widget assetFromCacheOrGenerate({
    String? asset,
    AssetType? assetType,
    double? height,
    double? width,
    ImageDetails? imageDetails,
    Color? foreground,
    Color? background,
  }) {
    asset = asset ?? '';
    var assetType = Asset.assetTypeOf(asset);
    var cacheKey = IconCacheKey(
      asset: asset,
      height: height ?? 40,
      width: width ?? 40,
      assetType: assetType,
    );
    return //cache[cacheKey] ??
        assetAvatarGeneratedAlphacon(
      asset: asset,
      assetType: assetType,
      height: height,
      width: width,
      imageDetails: imageDetails,
      foreground: foreground,
      background: background,
      cacheKey: cacheKey,
    );
  }

  /*
  ImageDetails getImageDetailsIdenticon([
    String? asset,
    Color? foreground,
    Color? background,
  ]) =>
      Identicon(
        background: foreground,
        foreground: background,
      ).generate(
        asset ?? '',
      );


  Widget assetAvatarGeneratedIdenticon({
    String? asset,
    double? height,
    double? width,
    ImageDetails? imageDetails,
    AssetType? assetType,
    Color? foreground,
    Color? background,
    IconCacheKey? cacheKey,
  }) {
    height = height ?? 40;
    width = width ?? 40;
    imageDetails = imageDetails ??
        getImageDetailsIdenticon(
          asset,
          foreground,
          background,
        );
    var indicator = generateIndicator(name: asset, imageDetails: imageDetails);
    var ret = Stack(alignment: Alignment.bottomRight, children: <Widget>[
      Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.fromARGB(
              255,
              imageDetails.background[0],
              imageDetails.background[1],
              imageDetails.background[2],
            ),
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
    if (cacheKey != null) {
      cache[cacheKey] = ret;
    }
    return ret;
  }
*/

  ImageDetails getImageDetailsAlphacon([
    String? asset,
    Color? foreground,
    Color? background,
  ]) =>
      Alphacon(
        background: foreground,
        foreground: background,
      ).generate(
        asset ?? '',
      );

  Widget assetAvatarGeneratedAlphacon({
    String? asset,
    double? height,
    double? width,
    ImageDetails? imageDetails,
    AssetType? assetType,
    Color? foreground,
    Color? background,
    IconCacheKey? cacheKey,
  }) {
    height = height ?? 40;
    width = width ?? 40;
    imageDetails = imageDetails ??
        getImageDetailsAlphacon(
          asset,
          foreground,
          background,
        );
    var indicator = generateIndicator(name: asset, imageDetails: imageDetails);
    var ret = Stack(alignment: Alignment.bottomRight, children: <Widget>[
      Container(
          height: height,
          width: width,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(
                255,
                imageDetails.background[0],
                imageDetails.background[1],
                imageDetails.background[2],
              ),
              border: Border.all(
                  width: 2,
                  color: Color.fromARGB(
                    255,
                    imageDetails.foreground[0],
                    imageDetails.foreground[1],
                    imageDetails.foreground[2],
                  ))),
          child: Text(() {
            final x = (asset?.split(RegExp(r'[/#$~]')).last ?? '☾');
            if (x == '') {
              return '☾';
            }
            return x.substring(0, 1).toUpperCase();
          }(),
              style: Theme.of(components.navigator.routeContext!)
                  .textTheme
                  .headline1!
                  .copyWith(
                      fontSize: (height + width) * .3,
                      color: AppColors.white87))),
      if (indicator != null) indicator,
    ]);
    if (cacheKey != null) {
      cache[cacheKey] = ret;
    }
    return ret;
  }

  Widget? generateIndicator({
    String? name,
    required ImageDetails imageDetails,
    double? height,
    double? width,
    AssetType? assetType,
  }) {
    height ??= 18;
    width ??= 18;
    assetType =
        assetType ?? (name != null ? Asset.assetTypeOf(name) : AssetType.main);
    if (assetType != AssetType.main) {
      return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
              color: Color.fromARGB(
                255,
                imageDetails.background[0],
                imageDetails.background[1],
                imageDetails.background[2],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                  width: 1,
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
                      child: Icon(assetTypeIcon(assetType: assetType),
                          size: (height + width) / 3,
                          color:
                              getIndicatorColor(imageDetails.background))))));
    }
    return null;
  }

  Color getIndicatorColor(List<int> backgroundColor) =>
      (backgroundColor.sum() / backgroundColor.length) >= 128 + 64
          ? Colors.black
          : Colors.white;

  IconData? assetTypeIcon({String? name, AssetType? assetType}) {
    if (assetType == null && name == null) {
      return null;
    }
    switch (assetType ?? Asset.assetTypeOf(name!)) {
      case AssetType.admin:
        return MdiIcons.crown;
      case AssetType.channel:
        return MdiIcons.message;
      case AssetType.unique:
        return MdiIcons.diamond;
      case AssetType.main:
        return Icons.circle_outlined;
      case AssetType.qualifier:
        return MdiIcons.pound;
      case AssetType.qualifierSub:
        return MdiIcons.pound;
      case AssetType.restricted:
        return MdiIcons.lock;
      case AssetType.sub:
        return MdiIcons.slashForward;
      case AssetType.subAdmin:
        return MdiIcons.crown;
      default:
        return Icons.circle_outlined;
    }
  }

/*
import 'package:ravencoin_front/widgets/other/circle_gradient.dart';
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
      Stack(children: <Widget>[PopCircle(colorPair: background), foreground]);

*/
/*
  import 'package:ravencoin_front/services/identicon.dart';
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
    //return Stack(children: <Widget>[
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
                  asset.endsWith('!') ? Color(0xFFFF9900) : AppColors.primary)),
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

class IconCacheKey with EquatableMixin {
  final String asset;
  final AssetType assetType;
  final double height;
  final double width;
  IconCacheKey({
    required this.asset,
    required this.assetType,
    required this.height,
    required this.width,
  });
  @override
  List<Object> get props => [asset, assetType, height, width];

  @override
  String toString() {
    return 'IconCacheKey($asset, $height, $width, $assetType)';
  }
}
