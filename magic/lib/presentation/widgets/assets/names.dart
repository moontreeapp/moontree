import 'package:flutter/material.dart';
import 'package:magic/domain/concepts/holding.dart';
import 'package:magic/presentation/theme/text.dart';

class HighlightedNameView extends StatelessWidget {
  final Holding holding;
  final TextStyle? parentsStyle;
  final TextStyle? childStyle;
  const HighlightedNameView({
    super.key,
    required this.holding,
    this.parentsStyle,
    this.childStyle,
  });

  @override
  Widget build(BuildContext context) => Container(
      alignment: Alignment.bottomCenter,
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.start,
          children: holding.assetPathIsAChild
              ? [
                  Text('${holding.assetPathParents}/',
                      style: parentsStyle ?? AppText.parentsAssetName),
                  Text(holding.assetPathChild,
                      style: childStyle ?? AppText.childAssetName),
                ]
              : [
                  Text(holding.name,
                      style: childStyle ?? AppText.childAssetName),
                ]));
}
