import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:wallet_utils/wallet_utils.dart' show SatsToAmountExtension;
import 'package:client_back/client_back.dart';
import 'package:client_front/application/manage/create/cubit.dart';
import 'package:client_front/presentation/services/services.dart';
import 'package:client_front/presentation/widgets/other/buttons.dart';
import 'package:client_front/presentation/theme/extensions.dart';
import 'package:client_front/presentation/theme/theme.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;

class SimpleCreateCheckout extends StatelessWidget {
  const SimpleCreateCheckout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SimpleCreateFormCubit cubit = components.cubits.simpleCreateForm;
    return BlocBuilder<SimpleCreateFormCubit, SimpleCreateFormState>(
      builder: (BuildContext context, SimpleCreateFormState state) {
        return CustomScrollView(
          shrinkWrap: true,
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 12),
                  ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    leading: components.icons.assetAvatar(
                      state.fullname.toUpperCase(),
                      chain: pros.settings.chain,
                      net: pros.settings.net,
                    ),
                    title: Row(children: <Widget>[
                      const SizedBox(width: 5),
                      Container(
                          width: MediaQuery.of(context).size.width -
                              (16 + 40 + 16 + 5 + 16),
                          child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                state.name,
                                style: Theme.of(context).textTheme.bodyLarge,
                              )))
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
                          if (state.parentName != '')
                            CheckoutItem(
                              left: 'Parent Asset',
                              right: state.parentName,
                            ),
                          CheckoutItem(
                            left: 'Asset',
                            right: state.fullname,
                          ),
                          CheckoutItem(
                            left: 'Quantity',
                            right: state.quantityCoin.toCommaString(),
                          ),
                          CheckoutItem(
                            left: 'Decimal Places',
                            right: state.decimals.toString(),
                          ),
                          if (!['', null].contains(state.assetMemo))
                            CheckoutItem(
                              left: cubit.assetMemoIsMemo
                                  ? 'Return Memo'
                                  : 'IPFS / Data',
                              right: state.assetMemo?.cutOutMiddle() ?? '',
                            ),
                          if (!['', null].contains(state.memo))
                            CheckoutItem(
                              left: 'Return Memo',
                              right: state.memo?.cutOutMiddle() ?? '',
                            ),
                          CheckoutItem(
                            left: 'Reissuable',
                            right: state.reissuable ? 'yes' : 'no',
                          ),
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
                  if (state.type != null)
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 16, right: 16, bottom: 7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          ...<Widget>[
                            Text('Fees',
                                style:
                                    Theme.of(context).textTheme.checkoutFees),
                            const SizedBox(height: 14),
                            CheckoutItem(
                                left: state.assetCreationName,
                                right: state.assetCreationFee.toCommaString(),
                                fee: true),
                            CheckoutItem(
                                left: 'Standard Transaction',
                                right: state.fee == null
                                    ? 'Calculating...'
                                    : '${state.fee!.asCoin}',
                                fee: true),
                          ],
                        ],
                      ),
                    ),
                  const Divider(indent: 0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                          padding: const EdgeInsets.only(
                              top: 10, left: 16, right: 16),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Total:',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                Text(
                                  state.fee == null
                                      ? 'Calculating...'
                                      : '${(state.assetCreationFeeSats + state.fee!).asCoin} ${pros.settings.chain.symbol}',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
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
                                state: state,
                                startTime: DateTime.now(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class CheckoutItem extends StatelessWidget {
  final String left;
  final String right;
  final bool fee;

  const CheckoutItem({
    required this.left,
    required this.right,
    this.fee = false,
  });

  @override
  Widget build(BuildContext context) => Padding(
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
                  softWrap: false,
                  maxLines: 1,
                ),
              ),
          ],
        ),
      );
}

class SubmitButton extends StatelessWidget {
  final SimpleCreateFormState state;
  final DateTime startTime;
  const SubmitButton({super.key, required this.state, required this.startTime});

  @override
  Widget build(BuildContext context) => BottomButton(
        enabled: true,
        label: 'Create',
        onPressed: () async {
          if (DateTime.now().difference(startTime).inMilliseconds > 500) {
            components.cubits.loadingView.show(
              title: 'Creating',
              msg: state.assetCreationName,
            );
            () async {
              await components.cubits.simpleCreateForm.broadcast();
            }();
            await Future.delayed(Duration(seconds: 3));
            components.cubits.loadingView.hide();
            await Future.delayed(Duration(milliseconds: 50));
            sail.home();
          }
        },
      );
}
