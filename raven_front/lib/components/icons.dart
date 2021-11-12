import 'package:flutter/material.dart';
import 'package:raven/records/records.dart';
import 'package:raven_mobile/theme/extensions.dart';

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

  String assetImage(asset) =>
      {'RVN': 'assets/rvn.png'}[asset] ?? 'assets/defaultBag.png';

  //CircleAvatar assetAvatar(asset) =>
  //    CircleAvatar(backgroundImage: AssetImage(assetImage(asset)));
  //ClipRRect assetAvatar(asset) => ClipRRect(
  //    // borderRadius: BorderRadius.circular(20.0), //or 15.0
  //    child: Image.asset(assetImage(asset)));
  Image assetAvatar(asset) => Image.asset(assetImage(asset));

  CircleAvatar appAvatar() =>
      CircleAvatar(backgroundImage: AssetImage('assets/rvn256.png'));

  CircleAvatar accountAvatar() =>
      CircleAvatar(backgroundImage: AssetImage('assets/rvn256.png'));

  CircleAvatar walletAvatar(Wallet wallet) => wallet is LeaderWallet
      ? CircleAvatar(backgroundImage: AssetImage('assets/rvn256.png'))
      : CircleAvatar(backgroundImage: AssetImage('assets/rvn256.png'));
}
