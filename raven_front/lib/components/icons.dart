import 'package:flutter/material.dart';
import 'package:raven/records/records.dart';
import 'package:fnv/fnv.dart';

import 'package:raven_mobile/theme/extensions.dart';
import 'package:raven_mobile/widgets/circle_gradient.dart';

class IconComponents {
  IconComponents();

  Icon get back => Icon(Icons.arrow_back, color: Colors.grey[100]);

  Icon income(BuildContext context) =>
      Icon(Icons.south_west, size: 12.0, color: Theme.of(context).good);

  Icon out(BuildContext context) =>
      Icon(Icons.north_east, size: 12.0, color: Theme.of(context).bad);

  Icon importDisabled(BuildContext context) =>
      Icon(Icons.add_box_outlined, color: Theme.of(context).disabledColor);

  Icon get import => Icon(Icons.add_box_outlined);

  Icon get export => Icon(Icons.save);

  String masterAssetImage(String asset) =>
      {'RVN': 'assets/rvn.png'}[asset] ?? 'assets/defaultMasterBag.png';

  Widget assetAvatar(String asset) {
    if (asset == 'RVN') {
      return Image.asset('assets/rvn.png');
    } else if (asset.endsWith('!')) {
      return Image.asset(masterAssetImage(asset));
    } else {
      var i = fnv1a_64(asset.codeUnits);
      var colorPair = gradients[i % gradients.length];
      return Stack(children: [
        PopCircle(
          colorPair: colorPair,
        ),
        Image.asset('assets/assetbag_transparent.png')
      ]);
    }
  }

  CircleAvatar appAvatar() =>
      CircleAvatar(backgroundImage: AssetImage('assets/rvn256.png'));

  CircleAvatar accountAvatar() =>
      CircleAvatar(backgroundImage: AssetImage('assets/rvn256.png'));

  CircleAvatar walletAvatar(Wallet wallet) => wallet is LeaderWallet
      ? CircleAvatar(backgroundImage: AssetImage('assets/rvn256.png'))
      : CircleAvatar(backgroundImage: AssetImage('assets/rvn256.png'));
}
