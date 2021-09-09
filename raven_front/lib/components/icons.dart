import 'package:flutter/material.dart';
import 'package:raven/records/records.dart';
import 'package:raven_mobile/theme/extensions.dart';

Icon backIcon() => Icon(Icons.arrow_back, color: Colors.grey[100]);
Icon inIcon(BuildContext context) =>
    Icon(Icons.south_west, size: 12.0, color: Theme.of(context).good);
Icon outIcon(BuildContext context) =>
    Icon(Icons.north_east, size: 12.0, color: Theme.of(context).bad);
Icon importDisabledIcon(BuildContext context) =>
    Icon(Icons.add_box_outlined, color: Theme.of(context).disabledColor);
Icon importIcon() => Icon(Icons.add_box_outlined);
Icon exportIcon() => Icon(Icons.save);

/// assumes there is no asset name RVN...
AssetImage assetIcon(String asset) =>
    {'RVN': AssetImage('assets/rvnhead.png')}[asset] ??
    AssetImage('assets/defaultasset.png');
CircleAvatar assetCircleAvatar(String asset) =>
    CircleAvatar(backgroundImage: assetIcon(asset));
CircleAvatar appCircleAvatar() =>
    CircleAvatar(backgroundImage: AssetImage('assets/rvn256.png'));

CircleAvatar accountCircleAvatar() =>
    CircleAvatar(backgroundImage: AssetImage('assets/rvn256.png'));
CircleAvatar walletCircleAvatar(Wallet wallet) => wallet is LeaderWallet
    ? CircleAvatar(backgroundImage: AssetImage('assets/rvn256.png'))
    : CircleAvatar(backgroundImage: AssetImage('assets/rvn256.png'));

class RavenIcon {
  RavenIcon();

  static Icon get back => backIcon();
  static Icon income(BuildContext context) => inIcon(context);
  static Icon out(BuildContext context) => outIcon(context);
  static Icon importDisabled(BuildContext context) =>
      importDisabledIcon(context);
  static Icon get import => importIcon();
  static Icon get export => exportIcon();
  static AssetImage assetImage(asset) => assetIcon(asset ?? 'RVN');
  static CircleAvatar assetAvatar(asset) => assetCircleAvatar(asset ?? 'RVN');
  static CircleAvatar appAvatar() => appCircleAvatar();
  static CircleAvatar accountAvatar() => accountCircleAvatar();
  static CircleAvatar walletAvatar(Wallet wallet) => walletCircleAvatar(wallet);
}
