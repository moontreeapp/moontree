import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:wallet_utils/wallet_utils.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/services/transaction/maker.dart';
import 'package:client_front/application/wallet/send/cubit.dart';
import 'package:client_front/presentation/services/services.dart';
import 'package:client_front/presentation/widgets/other/buttons.dart';
import 'package:client_front/presentation/theme/extensions.dart';
import 'package:client_front/presentation/theme/theme.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;

class SimpleSendCheckout extends StatelessWidget {
  SimpleSendCheckout({Key? key}) : super(key: key);

  String getRightTotal(String x, SimpleSendFormState state) {
    if ((state.checkout!.estimate?.fees ?? 0) > 0) {
      if ((state.checkout!.estimate?.security?.isCoin ?? true) &&
          (state.checkout!.estimate?.sendAll ?? false)) {
        return state.checkout!.estimate!.amount.asCoin.toCommaString();
      }
      return state.checkout!.estimate!.total.asCoin.toCommaString();
    }
    return x;
  }

  @override
  Widget build(BuildContext buildContext) =>
      BlocBuilder<SimpleSendFormCubit, SimpleSendFormState>(
          builder: (BuildContext context, SimpleSendFormState state) {
        return CustomScrollView(shrinkWrap: true, slivers: <Widget>[
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 12),
                ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  leading: state.checkout!.icon ??
                      components.icons.assetAvatar(
                          state.checkout!.symbol!.toUpperCase(),
                          net: pros.settings.net),
                  title: Row(children: <Widget>[
                    const SizedBox(width: 5),
                    Container(
                        width: MediaQuery.of(context).size.width -
                            (16 + 40 + 16 + 5 + 16),
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
                ),
                const Divider(indent: 16 + 56),
                const SizedBox(height: 14),
                Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ...[
                          for (final Iterable<String> pair
                              in state.checkout!.items)
                            CheckoutItem(
                              pair: pair,
                              estimate: state.checkout!.estimate,
                            ),
                        ]
                      ],
                    )),
                const SizedBox(height: 16),
                //Divider(indent: 16),
              ],
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (state.checkout!.fees != null)
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 7),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text('Fees',
                              style: Theme.of(context).textTheme.checkoutFees),
                          const SizedBox(height: 14),
                          ...[
                            for (final Iterable<String> pair
                                in state.checkout!.fees!)
                              CheckoutItem(
                                pair: pair,
                                estimate: state.checkout!.estimate,
                                fee: true,
                              ),
                          ]
                        ]),
                  ),
                const Divider(indent: 0),
                if (state.checkout!.total != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                          padding: const EdgeInsets.only(
                              top: 10, left: 16, right: 16),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Total:',
                                    style:
                                        Theme.of(context).textTheme.bodyLarge),
                                Text(
                                    '${getRightTotal(state.checkout!.total!, state)} ${state.checkout!.paymentSymbol!.toUpperCase()}',
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                    key: Key('checkoutTotal')),
                              ])),
                      const SizedBox(height: 40),
                      Padding(
                          padding: EdgeInsets.only(
                              top: 0, right: 16, bottom: 24, left: 16),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                    child: SubmitButton(
                                        startTime: DateTime.now(),
                                        state: state))
                              ])),
                    ],
                  ),
                if (state.checkout!.confirm != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                          padding: const EdgeInsets.only(
                              top: 10, left: 16, right: 16),
                          child: Container(
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
                          )),
                      Padding(
                          padding: const EdgeInsets.only(
                              top: 0, right: 16, bottom: 24, left: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                  child: state.checkout!.button == null
                                      ? SubmitButton(
                                          startTime: DateTime.now(),
                                          state: state)
                                      : state.checkout!.button!)
                            ],
                          ))
                    ],
                  ),
              ],
            ),
          )
        ]);
      });
}

class CheckoutItem extends StatelessWidget {
  final Iterable<String> pair;
  final bool fee;
  final SendEstimate? estimate;

  const CheckoutItem({
    required this.pair,
    required this.estimate,
    this.fee = false,
  });

  String getRightAmount(String x) {
    if ((estimate?.fees ?? 0) > 0) {
      if ((estimate?.security?.isCoin ?? true) &&
          (estimate?.sendAll ?? false)) {
        return (estimate!.amount - estimate!.fees).asCoin.toCommaString();
      }
      return estimate!.amount.asCoin.toCommaString();
    }
    return x;
  }

  String getRightFee(String x) {
    if ((estimate?.fees ?? 0) > 0) {
      return estimate!.fees.asCoin.toString();
    }
    return x;
  }

  @override
  Widget build(BuildContext context) {
    final left = pair.first;
    final right =
        ['To', 'IPFS', 'IPFS/TxId', 'ID', 'TxId', 'Note', 'Memo'].contains(left)
            ? pair.last.cutOutMiddle()
            : fee
                ? getRightFee(pair.toList()[1])
                : getRightAmount(pair.toList()[1]);
    //final style = fee ? Theme.of(context).textTheme.checkoutItem : Theme.of(context).textTheme.checkoutFee;
    return Padding(
      padding: EdgeInsets.only(bottom: 21),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: (screen.width - 16 - 16 - 8) * .5,
            child: Text(
              left,
              style: Theme.of(context).textTheme.checkoutItem,
              overflow: TextOverflow.fade,
              softWrap: false,
              maxLines: 1,
            ),
          ),
          if (fee || right.length < 21)
            Text(right,
                style: Theme.of(context).textTheme.checkoutItem,
                textAlign: TextAlign.right)
          else
            SizedBox(
              width: (screen.width - 16 - 16 - 8) * (1 - .5),
              child: Text(
                "$right${fee ? ' ${pros.settings.chain.symbol}' : ''}",
                style: Theme.of(context).textTheme.checkoutItem,
                textAlign: TextAlign.right,
                overflow: TextOverflow.fade,
                softWrap: pair.length != 2,
                maxLines: pair.length == 2 ? 1 : int.parse(pair.toList()[2]),
              ),
            ),
        ],
      ),
    );
  }
}

class SubmitButton extends StatelessWidget {
  final SimpleSendFormState state;
  final DateTime startTime;
  const SubmitButton({super.key, required this.state, required this.startTime});

  @override
  Widget build(BuildContext context) => BottomButton(
        enabled: !state.checkout!.disabled,
        label: state.checkout!.buttonWord,
        onPressed: () async {
          if (DateTime.now().difference(startTime).inMilliseconds > 500) {
            components.cubits.loadingView
                .show(title: 'Sending', msg: 'broadcasting transaction');
            state.checkout!.buttonAction!();
            await Future.delayed(Duration(seconds: 3));
            components.cubits.loadingView.hide();
            await Future.delayed(Duration(milliseconds: 50));
            //sail.home();
            sail.directlyTohome();
          }
        },
      );
}
