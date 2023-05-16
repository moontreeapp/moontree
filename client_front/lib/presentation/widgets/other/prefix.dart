import 'package:flutter/material.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;

class PrefixAssetCoinIcon extends StatelessWidget {
  final String symbol;
  const PrefixAssetCoinIcon({
    super.key,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
      height: 32,
      width: 32,
      child: Padding(
          padding: EdgeInsets.only(left: 12, top: 6, bottom: 8, right: 8),
          child: components.icons
              .assetAvatar(symbol, size: 32, net: pros.settings.net)));
}
