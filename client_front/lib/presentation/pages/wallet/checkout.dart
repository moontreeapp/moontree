import 'package:client_front/application/wallet/send/cubit.dart';
import 'package:client_front/presentation/services/services.dart';
import 'package:client_front/presentation/widgets/front_curve.dart';
import 'package:client_front/presentation/widgets/other/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intersperse/intersperse.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;
import 'package:client_front/presentation/theme/extensions.dart';
import 'package:client_front/presentation/theme/theme.dart';
import 'package:wallet_utils/wallet_utils.dart';

enum TransactionType { spend, create, reissue, export }

class SimpleSendCheckout extends StatelessWidget {
  final TransactionType? transactionType;

  SimpleSendCheckout({required this.transactionType, Key? key})
      : super(key: key);

  // on cubit?
  //late SendEstimate? estimate;
  // on cubit?
  //late bool disabled = false;
  // on cubit?
  late DateTime startTime;
  late SimpleSendFormState state; // remove in uiv3
  late BuildContext context;

  @override
  Widget build(BuildContext buildContext) {
    context = buildContext;
    startTime = DateTime.now();
    return FrontCurve(child: body());
  }

  Widget body() => BlocBuilder<SimpleSendFormCubit, SimpleSendFormState>(
          builder: (BuildContext context, SimpleSendFormState cubitState) {
        state = cubitState;
        return CustomScrollView(shrinkWrap: true, slivers: <Widget>[
          topPart,
          bottomPart,
        ]);
      });

  Widget get topPart => SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 12),
            header,
            const Divider(indent: 16 + 56),
            const SizedBox(height: 14),
            transactionItems,
            const SizedBox(height: 16),
            //Divider(indent: 16),
          ],
        ),
      );

  Widget get header => ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        leading: state.checkout!.icon ??
            components.icons.assetAvatar(state.checkout!.symbol!.toUpperCase(),
                net: pros.settings.net),
        title: Row(children: <Widget>[
          const SizedBox(width: 5),
          Container(
              width:
                  MediaQuery.of(context).size.width - (16 + 40 + 16 + 5 + 16),
              child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(state.checkout!.displaySymbol,
                      style: Theme.of(context).textTheme.bodyLarge)))
        ]),
        //subtitle: Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
        //  const SizedBox(width: 5),
        //  Text(state.checkout!.subSymbol!.toUpperCase(),
        //      style: Theme.of(context).checkoutSubAsset),
        //])
      );

  Widget get transactionItems => Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ...detailItems(
            pairs: state.checkout!.items,
            style: Theme.of(context).textTheme.checkoutItem,
          )
        ],
      ));

  Iterable<Widget> detailItems({
    required Iterable<Iterable<String>> pairs,
    TextStyle? style,
    bool fee = false,
  }) {
    final List<Widget> rows = <Widget>[];

    for (final Iterable<String> pair in pairs) {
      String rightSide;
      if (<String>['To', 'IPFS', 'IPFS/TxId', 'ID', 'TxId', 'Note', 'Memo']
          .contains(pair.first)) {
        rightSide = pair.last.cutOutMiddle();
      } else {
        rightSide = fee
            ? getRightFee(pair.toList()[1])
            : getRightAmount(pair.toList()[1]);
      }
      rows.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
                width: (MediaQuery.of(context).size.width - 16 - 16 - 8) *
                    (state.checkout!.left ?? .5),
                child: Text(pair.toList()[0],
                    style: style,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    maxLines: 1)),
            if (fee || rightSide.length < 21)
              Text(rightSide, style: style, textAlign: TextAlign.right)
            else
              SizedBox(
                  width: (MediaQuery.of(context).size.width - 16 - 16 - 8) *
                      (1 - (state.checkout!.left ?? .5)),
                  child: Text(
                    rightSide,
                    style: style,
                    textAlign: TextAlign.right,
                    overflow: pair.length == 2
                        ? TextOverflow.fade
                        : TextOverflow.fade,
                    softWrap: pair.length != 2,
                    maxLines:
                        pair.length == 2 ? 1 : int.parse(pair.toList()[2]),
                  )),
          ]));
    }
    return rows.intersperse(const SizedBox(height: 21));
  }

  String getRightAmount(String x) {
    if ((state.checkout!.estimate?.fees ?? 0) > 0) {
      if (state.checkout!.estimate?.sendAll ?? false) {
        return (state.checkout!.estimate!.amount -
                state.checkout!.estimate!.fees)
            .asCoin
            .toString();
      }
      return state.checkout!.estimate!.amount.asCoin.toString();
    }
    return x;
  }

  String getRightFee(String x) {
    if ((state.checkout!.estimate?.fees ?? 0) > 0) {
      return state.checkout!.estimate!.fees.asCoin.toString();
    }
    return x;
  }

  Widget get bottomPart => SliverFillRemaining(
        hasScrollBody: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (state.checkout!.fees != null)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ...fees,
                  ],
                ),
              ),
            const Divider(indent: 0),
            if (state.checkout!.total != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                      padding:
                          const EdgeInsets.only(top: 10, left: 16, right: 16),
                      child: total),
                  const SizedBox(height: 40),
                  Padding(
                      padding: EdgeInsets.only(
                          top: 0, right: 16, bottom: 24, left: 16),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [Expanded(child: submitButton)])),
                ],
              ),
            if (state.checkout!.confirm != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                      padding:
                          const EdgeInsets.only(top: 10, left: 16, right: 16),
                      child: confirm),
                  Padding(
                      padding: const EdgeInsets.only(
                          top: 0, right: 16, bottom: 24, left: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                              child: state.checkout!.button == null
                                  ? submitButton
                                  : state.checkout!.button!)
                        ],
                      ))
                ],
              ),
          ],
        ),
      );

  List<Widget> get fees => <Widget>[
        Text('Fees', style: Theme.of(context).textTheme.checkoutFees),
        const SizedBox(height: 14),
        ...detailItems(
          pairs: state.checkout!.fees!,
          style: Theme.of(context).textTheme.checkoutFee,
          fee: true,
        ),
      ];

  Widget get total =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
        Text('Total:', style: Theme.of(context).textTheme.bodyLarge),
        Text(
            '${getRightTotal(state.checkout!.total!)} ${state.checkout!.paymentSymbol!.toUpperCase()}',
            style: Theme.of(context).textTheme.bodyLarge,
            key: Key('checkoutTotal')),
      ]);

  Widget get confirm => Container(
        height: 60,
        alignment: Alignment.center,
        child: Text(
          state.checkout!.confirm!,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
          softWrap: true,
          overflow: TextOverflow.fade,
          maxLines: 3,
        ),
      );

  String getRightTotal(String x) {
    if ((state.checkout!.estimate?.fees ?? 0) > 0) {
      if (state.checkout!.estimate?.sendAll ?? false) {
        return state.checkout!.estimate!.amount.asCoin.toString();
      }
      return state.checkout!.estimate!.total.asCoin.toString();
    }
    return x;
  }

  Widget get submitButton => BottomButton(
        enabled: !state.checkout!.disabled,
        label: state.checkout!.buttonWord,
        onPressed: () async {
          if (DateTime.now().difference(startTime).inMilliseconds > 500) {
            //await components.loading.screen(
            //  message: state.checkout!.loadingMessage,
            //  playCount: state.checkout!.playcount ?? 2,
            //);
            components.cubits.loadingView
                .show(title: 'Sending', msg: 'broadcasting transaction');
            state.checkout!.buttonAction!();
            await Future.delayed(Duration(seconds: 3));
            components.cubits.loadingView.hide();
            await Future.delayed(Duration(milliseconds: 50));
            sail.home();
          }
        },
      );
}
