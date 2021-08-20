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
CircleAvatar assetCircleAvatar(String asset) => CircleAvatar(
      backgroundImage: assetIcon(asset),
    );

class RavenIcon {
  BuildContext? context;
  String? asset;
  RavenIcon({this.context, this.asset});
  Icon get back => backIcon();
  Icon get income => inIcon(context);
  Icon get out => outIcon(context);
  AssetImage get assetImage => assetIcon(asset ?? 'RVN');
  CircleAvatar get assetAvatar => assetCircleAvatar(asset ?? 'RVN');
}
