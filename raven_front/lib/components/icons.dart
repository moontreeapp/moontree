import 'package:flutter/material.dart';
import 'package:raven/records/records.dart';
import 'package:raven_mobile/theme/extensions.dart';

Icon backIcon() => Icon(Icons.arrow_back, color: Colors.grey[100]);
Icon inIcon(context) =>
    Icon(Icons.south_west, size: 12.0, color: Theme.of(context).good);
Icon outIcon(context) =>
    Icon(Icons.north_east, size: 12.0, color: Theme.of(context).bad);

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
  static Icon income(context) => inIcon(context);
  static Icon out(context) => outIcon(context);
  static AssetImage assetImage(asset) => assetIcon(asset ?? 'RVN');
  static CircleAvatar assetAvatar(asset) => assetCircleAvatar(asset ?? 'RVN');
  static CircleAvatar appAvatar() => appCircleAvatar();
  static CircleAvatar accountAvatar() => accountCircleAvatar();
  static CircleAvatar walletAvatar(Wallet wallet) => walletCircleAvatar(wallet);
}
