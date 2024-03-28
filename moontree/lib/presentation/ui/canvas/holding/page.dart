import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moontree/cubits/cubit.dart';
import 'package:moontree/cubits/holding/cubit.dart';
import 'package:moontree/domain/concepts/transaction.dart';
import 'package:moontree/domain/concepts/sats.dart';
import 'package:moontree/presentation/utils/animation.dart';
import 'package:moontree/services/services.dart' show maestro, screen;
import 'package:moontree/presentation/theme/theme.dart';
import 'package:moontree/presentation/widgets/assets/icons.dart';

class HodingDetailPage extends StatelessWidget {
  const HodingDetailPage({super.key});

  /// AnimatedList solution:
  @override
  Widget build(BuildContext context) => Container(
      width: screen.width,
      height: screen.height,
      padding: EdgeInsets.only(top: screen.appbar.height),
      alignment: Alignment.topCenter,
      child: Container(
          width: screen.width,
          height: screen.canvas.midHeight,
          alignment: Alignment.center,
          child: const DynamicList()));

  /// AnimatedSwitcher solution:
  //@override
  //Widget build(BuildContext context) => Container(
  //      width: screen.width,
  //      height: screen.height,
  //      padding: EdgeInsets.only(top: screen.appbar.height),
  //      alignment: Alignment.topCenter,
  //      child: Container(
  //        width: screen.width,
  //        height: screen.canvas.midHeight,
  //        alignment: Alignment.center,
  //        child: Column(
  //          mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //          children: [
  //            const SizedBox.shrink(),
  //            Container(
  //              height: screen.iconHuge,
  //              width: screen.iconHuge,
  //              alignment: Alignment.center,
  //              decoration: BoxDecoration(
  //                color: AppColors.primary60,
  //                borderRadius: BorderRadius.circular(100),
  //              ),
  //              //child: SvgPicture.asset(
  //              //  '${TransactionIcons.base}/send.${TransactionIcons.ext}',
  //              //  alignment: Alignment.center,
  //              //),
  //            ),
  //            const SizedBox.shrink(),
  //            const SizedBox.shrink(),
  //            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
  //              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
  //                Text('whole.', style: AppText.wholeHolding),
  //                Text('part', style: AppText.partHolding),
  //              ]),
  //              Text('\$ usd', style: AppText.usdHolding),
  //            ]),
  //            const SizedBox.shrink(),
  //            const SizedBox.shrink(),
  //            const SizedBox.shrink(),
  //            BlocBuilder<HoldingCubit, HoldingState>(
  //                buildWhen: (HoldingState previous, HoldingState current) =>
  //                    current.active && previous.send != current.send,
  //                builder: (context, state) => AnimatedSwitcher(
  //                      duration: slideDuration,
  //                      child: state.send
  //                          ? const SizedBox.shrink()
  //                          : Row(
  //                              key: const ValueKey('HodingDetailsPageNotSend'),
  //                              mainAxisAlignment:
  //                                  MainAxisAlignment.spaceEvenly,
  //                              children: [
  //                                  const SizedBox.shrink(),
  //                                  const SizedBox.shrink(),
  //                                  GestureDetector(
  //                                      onTap: () => maestro.activateSend(),
  //                                      child: Column(
  //                                          mainAxisAlignment:
  //                                              MainAxisAlignment.center,
  //                                          children: [
  //                                            Container(
  //                                              height: screen.iconLarge,
  //                                              width: screen.iconLarge,
  //                                              alignment: Alignment.center,
  //                                              decoration: BoxDecoration(
  //                                                color: AppColors.primary60,
  //                                                borderRadius:
  //                                                    BorderRadius.circular(
  //                                                        100),
  //                                              ),
  //                                              child: SvgPicture.asset(
  //                                                '${TransactionIcons.base}/send.${TransactionIcons.ext}',
  //                                                alignment: Alignment.center,
  //                                              ),
  //                                            ),
  //                                            const SizedBox(height: 4),
  //                                            Text('send',
  //                                                style: AppText.labelHolding),
  //                                          ])),
  //                                  //SizedBox(width: screen.canvas.wSpace),
  //                                  Column(
  //                                      mainAxisAlignment:
  //                                          MainAxisAlignment.center,
  //                                      children: [
  //                                        Container(
  //                                          height: screen.iconLarge,
  //                                          width: screen.iconLarge,
  //                                          alignment: Alignment.center,
  //                                          decoration: BoxDecoration(
  //                                            color: AppColors.primary60,
  //                                            borderRadius:
  //                                                BorderRadius.circular(100),
  //                                          ),
  //                                          child: SvgPicture.asset(
  //                                            '${TransactionIcons.base}/receive.${TransactionIcons.ext}',
  //                                            alignment: Alignment.center,
  //                                          ),
  //                                        ),
  //                                        const SizedBox(height: 4),
  //                                        Text('receive',
  //                                            style: AppText.labelHolding),
  //                                      ]),
  //                                  //SizedBox(width: screen.canvas.wSpace),
  //                                  Column(
  //                                      mainAxisAlignment:
  //                                          MainAxisAlignment.center,
  //                                      children: [
  //                                        Container(
  //                                          height: screen.iconLarge,
  //                                          width: screen.iconLarge,
  //                                          alignment: Alignment.center,
  //                                          decoration: BoxDecoration(
  //                                            color: AppColors.primary60,
  //                                            borderRadius:
  //                                                BorderRadius.circular(100),
  //                                          ),
  //                                          child: SvgPicture.asset(
  //                                            '${TransactionIcons.base}/swap.${TransactionIcons.ext}',
  //                                            alignment: Alignment.center,
  //                                          ),
  //                                        ),
  //                                        const SizedBox(height: 4),
  //                                        Text('swap',
  //                                            style: AppText.labelHolding),
  //                                      ]),
  //                                  const SizedBox.shrink(),
  //                                  const SizedBox.shrink(),
  //                                ]),
  //                    )),
  //            const SizedBox.shrink(),
  //            const SizedBox.shrink(),
  //            const SizedBox.shrink(),
  //          ],
  //        ),
  //      ),
  //    );
}

class DynamicList extends StatefulWidget {
  const DynamicList({super.key});

  @override
  DynamicListState createState() => DynamicListState();
}

class DynamicListState extends State<DynamicList> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<Widget> _widgets = [];

  @override
  void initState() {
    super.initState();
    _widgets = [
      watcher(),
      assetIcon(),
      spacer(),
      assetValues(),
      bigSpacer(),
      buttons(),
    ];
  }

  Widget bigSpacer() => const SizedBox(height: 24);
  Widget spacer() => const SizedBox(height: 16);

  Widget watcher() => BlocBuilder<HoldingCubit, HoldingState>(
      buildWhen: (HoldingState previous, HoldingState current) =>
          current.active && previous.send != current.send,
      builder: (context, state) {
        if (state.prior?.send == true && !state.send) {
          _fromSend();
        } else if (state.prior?.send == false && state.send) {
          _toSend();
        }
        return const SizedBox.shrink();
      });

  Widget assetIcon() => Container(
      width: screen.width,
      alignment: Alignment.center,
      child: Container(
        height: screen.iconHuge,
        width: screen.iconHuge,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primary60,
          borderRadius: BorderRadius.circular(100),
        ),
        //child: SvgPicture.asset(
        //  '${TransactionIcons.base}/send.${TransactionIcons.ext}',
        //  alignment: Alignment.center,
        //),
      ));

  Widget assetValues() =>
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('whole.', style: AppText.wholeHolding),
          Text('part', style: AppText.partHolding),
        ]),
        Text('\$ usd', style: AppText.usdHolding),
      ]);

  Widget buttons() =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        GestureDetector(
            onTap: () => maestro.activateSend(),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                height: screen.iconLarge,
                width: screen.iconLarge,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary60,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: SvgPicture.asset(
                  '${TransactionIcons.base}/send.${TransactionIcons.ext}',
                  alignment: Alignment.center,
                ),
              ),
              const SizedBox(height: 4),
              Text('send', style: AppText.labelHolding),
            ])),
        //SizedBox(width: screen.canvas.wSpace),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            height: screen.iconLarge,
            width: screen.iconLarge,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary60,
              borderRadius: BorderRadius.circular(100),
            ),
            child: SvgPicture.asset(
              '${TransactionIcons.base}/receive.${TransactionIcons.ext}',
              alignment: Alignment.center,
            ),
          ),
          const SizedBox(height: 4),
          Text('receive', style: AppText.labelHolding),
        ]),
        //SizedBox(width: screen.canvas.wSpace),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            height: screen.iconLarge,
            width: screen.iconLarge,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary60,
              borderRadius: BorderRadius.circular(100),
            ),
            child: SvgPicture.asset(
              '${TransactionIcons.base}/swap.${TransactionIcons.ext}',
              alignment: Alignment.center,
            ),
          ),
          const SizedBox(height: 4),
          Text('swap', style: AppText.labelHolding),
        ]),
      ]);

  // 0 watcher(),
  // 1 bigSpacer(),
  // 2 assetIcon(),
  // 3 bigSpacer(),
  // 4 assetValues(),
  void _fromSend() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_widgets.length == 5) {
        for (final i in [3, 1]) {
          final item = _widgets.removeAt(i);
          _listKey.currentState?.removeItem(
            i,
            (context, animation) => _buildItem(item, animation),
            duration: slideDuration * 10,
          );
        }
        // 0 watcher(),
        // 1 assetIcon(),
        // 2 assetValues(),
        _widgets.insert(2, spacer());
        _listKey.currentState?.insertItem(0, duration: slideDuration * 10);
        // 0 watcher(),
        // 1 assetIcon(),
        // 2 spacer(),
        // 3 assetValues(),
        _widgets.insert(4, bigSpacer());
        _listKey.currentState?.insertItem(0, duration: slideDuration * 10);
        _widgets.insert(5, buttons());
        _listKey.currentState?.insertItem(0, duration: slideDuration * 10);
      }
    });
  }

  // 0 watcher(),
  // 1 assetIcon(),
  // 2 spacer(),
  // 3 assetValues(),
  // 4 bigSpacer(),
  // 5 buttons(),
  void _toSend() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_widgets.length == 6) {
        for (final i in [5, 4, 2]) {
          final item = _widgets.removeAt(i);
          _listKey.currentState?.removeItem(
            i,
            (context, animation) => _buildItem(item, animation),
            duration: slideDuration * 10,
          );
        }
        _widgets.insert(2, bigSpacer());
        _listKey.currentState?.insertItem(0, duration: slideDuration * 10);
        _widgets.insert(1, bigSpacer());
        _listKey.currentState?.insertItem(0, duration: slideDuration * 10);
      }
    });
  }

  Widget _buildItem(Widget item, Animation<double> animation) => SizeTransition(
      sizeFactor: CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutCirc,
      ),
      child: item);

  @override
  Widget build(BuildContext context) => AnimatedList(
      key: _listKey,
      initialItemCount: _widgets.length,
      itemBuilder: (context, index, animation) =>
          _buildItem(_widgets[index], animation));
}
