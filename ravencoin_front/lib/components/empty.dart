import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ravencoin_front/theme/theme.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/utils/extensions.dart';
import 'package:ravencoin_front/utils/zips.dart';
import 'package:shimmer/shimmer.dart';

class EmptyComponents {
  EmptyComponents();

  Container transactions(
    BuildContext context, {
    String? msg,
  }) =>
      _emptyMessage(
        context,
        icon: Icons.public,
        msg: msg ?? '\nYour transactions will appear here.\n',
      );

  Container holdings(
    BuildContext context, {
    String? msg,
  }) =>
      _emptyMessage(
        context,
        icon: Icons.savings,
        msg: msg ?? '\nYour holdings will appear here.\n',
      );

  Container message(
    BuildContext context, {
    required String msg,
    IconData? icon,
  }) =>
      _emptyMessage(
        context,
        icon: icon ?? Icons.savings,
        msg: msg,
      );

  static Container _emptyMessage(
    BuildContext context, {
    required String msg,
    IconData? icon,
  }) =>
      Container(
          alignment: Alignment.center,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon ?? Icons.savings,
                size: 50.0, color: Theme.of(context).secondaryHeaderColor),
            Text(msg),
            //RavenButton.getRVN(context), // hidden for alpha
          ]));

  ListView getZeroHoldingsPlaceholder(
    BuildContext context, {
    required ScrollController scrollController,
    int count = 1,
    bool holding = false,
  }) {
    final thisHolding = Shimmer.fromColors(
        baseColor: AppColors.primaries[0],
        highlightColor: Colors.white,
        child: assetPlaceholder(context, holding: holding));
    return ListView(
        controller: scrollController,
        dragStartBehavior: DragStartBehavior.start,
        physics: const ClampingScrollPhysics(),
        children: <Widget>[
          SizedBox(height: 8),
          ...[
            for (var _ in range(count)) ...[thisHolding, Divider()]
          ],
          ...[blankNavArea(context)]
        ]);
  }

  ListView getAssetsPlaceholder(
    BuildContext context, {
    ScrollController? scrollController,
    int count = 1,
    bool holding = false,
  }) {
    final thisHolding = Shimmer.fromColors(
        baseColor: AppColors.primaries[0],
        highlightColor: Colors.white,
        child: assetPlaceholder(context, holding: holding));
    return ListView(
        controller: scrollController,
        dragStartBehavior: DragStartBehavior.start,
        physics: const ClampingScrollPhysics(),
        children: <Widget>[
          SizedBox(height: 8),
          ...[
            for (var _ in range(count)) ...[thisHolding, Divider()]
          ],
          ...[blankNavArea(context)]
        ]);
  }

  Widget holdingPlaceholder(BuildContext context) => assetPlaceholder(
        context,
        holding: true,
      );

  Widget assetPlaceholder(
    BuildContext context, {
    bool holding = false,
  }) =>
      Container(
          height: 72,
          padding: EdgeInsets.only(top: 8.0, left: 16),
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaries[0],
                  border: Border.all(width: 2, color: AppColors.primaries[0])),
              //child: ClipRRect(borderRadius: BorderRadius.circular(100.0)),
            ),
            SizedBox(width: 16),
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (holding) ...[
                    Container(
                      height: MediaQuery.of(context).size.height * (12 / 760),
                      width: 79,
                      decoration: BoxDecoration(
                          color: AppColors.primaries[0],
                          borderRadius: BorderRadius.circular(
                              (MediaQuery.of(context).size.height *
                                      (12 / 760)) *
                                  .5)),
                    ),
                    SizedBox(height: 8),
                  ],
                  Container(
                    height: MediaQuery.of(context).size.height * (12 / 760),
                    width: 148,
                    decoration: BoxDecoration(
                        color: AppColors.primaries[0],
                        borderRadius: BorderRadius.circular(
                            (MediaQuery.of(context).size.height * (12 / 760)) *
                                .5)),
                  ),
                ])
          ]));

  Widget swapPlaceholder(BuildContext context) => ListTile(
      leading: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaries[0],
            border: Border.all(width: 2, color: AppColors.primaries[0])),
        //child: ClipRRect(borderRadius: BorderRadius.circular(100.0)),
      ),
      title: Row(children: [
        Container(
            height: MediaQuery.of(context).size.height * (12 / 760),
            width: 79,
            decoration: BoxDecoration(
                color: AppColors.primaries[0],
                borderRadius: BorderRadius.circular(
                    (MediaQuery.of(context).size.height * (12 / 760)) * .5)))
      ]),
      subtitle: Row(children: [
        Container(
            height: MediaQuery.of(context).size.height * (12 / 760),
            width: 148,
            decoration: BoxDecoration(
                color: AppColors.primaries[0],
                borderRadius: BorderRadius.circular(
                    (MediaQuery.of(context).size.height * (12 / 760)) * .5)))
      ]),
      trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * (12 / 760),
              width: 47,
              decoration: BoxDecoration(
                  color: AppColors.primaries[0],
                  borderRadius: BorderRadius.circular(
                      (MediaQuery.of(context).size.height * (12 / 760)) * .5)),
            ),
            SizedBox(height: 8),
            Container(
              height: MediaQuery.of(context).size.height * (12 / 760),
              width: 47,
              decoration: BoxDecoration(
                  color: AppColors.primaries[0],
                  borderRadius: BorderRadius.circular(
                      (MediaQuery.of(context).size.height * (12 / 760)) * .5)),
            ),
          ]));

  Widget blankNavArea(BuildContext context) => Container(
        height: 118.figma(context),
        color: Colors.white,
      );

  ListView getTransactionsPlaceholder(
    BuildContext context, {
    required ScrollController scrollController,
    int count = 1,
  }) {
    return ListView(
        controller: scrollController,
        dragStartBehavior: DragStartBehavior.start,
        physics: const ClampingScrollPhysics(),
        children: <Widget>[
          SizedBox(height: 8),
          ...[
            for (var _ in range(count)) ...[
              getTransactionsShimmer(context),
              Divider()
            ]
          ],
          ...[blankNavArea(context)]
        ]);
  }

  Widget getTransactionsShimmer(BuildContext context) => Shimmer.fromColors(
      baseColor: AppColors.primaries[0],
      highlightColor: Colors.white,
      child: transactionPlaceholder(context));

  Widget transactionPlaceholder(BuildContext context) => Container(
      height: 64,
      padding: EdgeInsets.only(top: 8.0, left: 16, right: 16),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * (12 / 760),
                width: 79,
                decoration: BoxDecoration(
                    color: AppColors.primaries[0],
                    borderRadius: BorderRadius.circular(
                        (MediaQuery.of(context).size.height * (12 / 760)) *
                            .5)),
              ),
              SizedBox(height: 8),
              Container(
                height: MediaQuery.of(context).size.height * (12 / 760),
                width: 148,
                decoration: BoxDecoration(
                    color: AppColors.primaries[0],
                    borderRadius: BorderRadius.circular(
                        (MediaQuery.of(context).size.height * (12 / 760)) *
                            .5)),
              ),
            ]),
        components.icons.out(context, color: AppColors.primaries[0])
      ]));
}