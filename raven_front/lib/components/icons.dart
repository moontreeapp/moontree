import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/services/storage.dart';
import 'package:raven_front/theme/theme.dart';
import 'package:raven_front/utils/identicon.dart';
import 'package:equatable/equatable.dart';

class IconComponents {
  Map<IconCacheKey, Widget> cache = {};

  Icon get back => Icon(Icons.chevron_left_rounded, color: Colors.white);

  Icon get close => Icon(Icons.close, color: Colors.white);

  Widget income(BuildContext context) =>
      Image.asset('assets/icons/receive/receive_green.png');

  Widget out(BuildContext context) =>
      Image.asset('assets/icons/send/send_red.png');

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
  }) {
    height = height ?? size;
    width = width ?? size;
    if (asset.toUpperCase() == 'RVN') {
      return _assetAvatarRVN(height: height, width: width);
    }
    var ret = _assetAvatarSecurity(asset, height: height, width: width);
    if (ret != null) {
      return ret;
    }
    return assetFromCacheOrGenerate(asset: asset, height: height, width: width);
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
    return cache[cacheKey] ??
        assetAvatarGeneratedIdenticon(
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

  ImageDetails getImageDetails([
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
        getImageDetails(
          asset,
          foreground,
          background,
        );
    var indicator = generateIndicator(name: asset, imageDetails: imageDetails);
    var ret = Stack(alignment: Alignment.bottomRight, children: [
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

  Widget? generateIndicator({
    String? name,
    required ImageDetails imageDetails,
    double? height,
    double? width,
    AssetType? assetType,
  }) {
    assetType =
        assetType ?? (name != null ? Asset.assetTypeOf(name) : AssetType.Main);
    if (assetType != AssetType.Main) {
      return Container(
          height: height ?? 24,
          width: width ?? 24,
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
                      child: Icon(assetTypeIcon(assetType: assetType),
                          size: 16,
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
      case AssetType.Admin:
        return MdiIcons.crown;
      case AssetType.Channel:
        return MdiIcons.message;
      case AssetType.NFT:
        return MdiIcons.diamond;
      case AssetType.Main:
        return Icons.circle_outlined;
      case AssetType.Qualifier:
        return Icons.ac_unit;
      case AssetType.QualifierSub:
        return Icons.ac_unit;
      case AssetType.Restricted:
        return MdiIcons.lock;
      case AssetType.RestrictedAdmin:
        return MdiIcons.lock;
      case AssetType.Sub:
        return MdiIcons.slashForward;
      case AssetType.SubAdmin:
        return MdiIcons.crown;
      default:
        return Icons.circle_outlined;
    }
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
