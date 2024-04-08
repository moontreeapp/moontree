import 'package:flutter/material.dart';

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
          padding: const EdgeInsets.only(left: 12, top: 6, bottom: 8, right: 8),
          child: Text(symbol)));
}
