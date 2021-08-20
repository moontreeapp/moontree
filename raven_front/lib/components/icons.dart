import 'package:flutter/material.dart';
import 'package:raven_mobile/theme/extensions.dart';

Icon backIcon() => Icon(Icons.arrow_back, color: Colors.grey[100]);
Icon inIcon(context) =>
    Icon(Icons.south_west, size: 12.0, color: Theme.of(context).good);
Icon outIcon(context) =>
    Icon(Icons.north_east, size: 12.0, color: Theme.of(context).bad);
AssetImage assetIcon(String asset) =>
    {'RVN': AssetImage('assets/rvnhead.png')}[asset] ??
    AssetImage('assets/defaultasset.png');
CircleAvatar assetCircleAvatar(String asset) =>
    CircleAvatar(backgroundImage: assetIcon(asset));

class RavenIcon {
  RavenIcon();

  static Icon get back => backIcon();
  static Icon income(context) => inIcon(context);
  static Icon out(context) => outIcon(context);
  static AssetImage assetImage(asset) => assetIcon(asset ?? 'RVN');
  static CircleAvatar assetAvatar(asset) => assetCircleAvatar(asset ?? 'RVN');
}
