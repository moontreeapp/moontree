/// Allows for importing two different ways, I prefer the later, See colors.dart
import 'package:flutter/material.dart';

Icon backIcon() => Icon(Icons.arrow_back, color: Colors.grey[100]);
Icon inIcon() => Icon(Icons.south_west, size: 12.0, color: Colors.green);
Icon outIcon() => Icon(Icons.north_east, size: 12.0, color: Colors.red);

AssetImage assetIcon(String name) {
  return {
        'rvn': AssetImage('assets/ravenhead.png'),
      }[name] ??
      AssetImage('assets/defaultasset.png');
}

class RavenIcons {
  RavenIcons();

  Icon get back => backIcon();
  Icon get income => inIcon();
  Icon get out => outIcon();
  AssetImage getAssetImage(String name) => assetIcon(name);
}
