import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/canvas/holding/cubit.dart';
import 'package:magic/cubits/cubit.dart';
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

class ResponsiveHighlightedNameView extends StatelessWidget {
  final TextStyle? parentsStyle;
  final TextStyle? childStyle;
  final Alignment alignment;
  const ResponsiveHighlightedNameView({
    super.key,
    this.parentsStyle,
    this.childStyle,
    this.alignment = Alignment.center,
  });

  String adminize(String name) =>
      name.endsWith('!') ? '${name.replaceAll('!', '')} (Admin)' : name;

  @override
  Widget build(BuildContext context) => BlocBuilder<HoldingCubit, HoldingState>(
      builder: (BuildContext context, HoldingState state) => Padding(
          padding: const EdgeInsets.only(left: 16, top: 2.0, right: 16),
          child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Container(
                  alignment: alignment,
                  //width: screen.appbar.titleWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: cubits.menu.isInHardMode
                        ? (state.holding.assetPathIsAChild
                            ? [
                                Text('${state.holding.assetPathParents}/',
                                    style: parentsStyle ??
                                        AppText.parentsAssetName),
                                Text(
                                  adminize(state.holding.assetPathChild),
                                  style: childStyle ?? AppText.childAssetName,
                                ),
                              ]
                            : [
                                Text(adminize(state.holding.name),
                                    style:
                                        childStyle ?? AppText.childAssetName),
                              ])
                        : state.holding.isCurrency
                            ? [
                                Text(state.holding.blockchain.name,
                                    style: childStyle ?? AppText.childAssetName)
                              ]
                            : [
                                Text(adminize(state.holding.assetPathChild),
                                    style: childStyle ?? AppText.childAssetName)
                              ],
                  )))));
}
