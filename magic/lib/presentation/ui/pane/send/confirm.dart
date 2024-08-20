import 'package:flutter/material.dart';
import 'package:magic/cubits/canvas/menu/cubit.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/domain/concepts/numbers/sats.dart';
import 'package:magic/presentation/theme/colors.dart';
import 'package:magic/presentation/theme/extensions.dart';
import 'package:magic/presentation/theme/text.dart';
import 'package:magic/presentation/ui/pane/wallet/page.dart';
import 'package:magic/presentation/widgets/assets/amounts.dart';
import 'package:magic/services/services.dart';

class ConfirmContent extends StatelessWidget {
  const ConfirmContent({super.key});

  Future<void> _send() async {
    //cubits.send.signUnsignedTransaction(); // already signed.
    await cubits.send.broadcast();
    print(cubits.send.state.txHashes);
    //cubits.toast.flash(msg: ToastMessage(title: 'transaction id', text: : cubits.send.state.txHashes));
    cubits.send.reset();
    await cubits.wallet.populateAssets();
    await Future.delayed(const Duration(seconds: 1));
    cubits.holding.update(active: false);
    await maestro.activateHistory(
      holding: cubits.wallet.state.holdings.firstWhere((holding) =>
          holding.blockchain == cubits.holding.state.holding.blockchain &&
          holding.symbol == cubits.holding.state.holding.symbol),
    );
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        height: screen.pane.midHeight,
        child:

            //      //ConfirmationItem(label: 'To:', display: <TextSpan>[
            //      //  TextSpan(
            //      //      text: 'address',
            //      //      style: Theme.of(context).textTheme.body1.copyWith(
            //      //            fontWeight: FontWeight.normal,
            //      //            color: AppColors.black87,
            //      //          )),
            //      //]),
            //      //ConfirmationItem(label: 'Amount:', display: <TextSpan>[
            //      //  TextSpan(
            //      //      text: '21,000,000,000',
            //      //      style: Theme.of(context).textTheme.body1.copyWith(
            //      //            fontWeight: FontWeight.normal,
            //      //            color: AppColors.black87,
            //      //          )),
            //      //  TextSpan(
            //      //      text: '.00000000',
            //      //      style: Theme.of(context).textTheme.body1.copyWith(
            //      //          fontWeight: FontWeight.normal,
            //      //          color: AppColors.black60,
            //      //          fontSize: 12)),
            //      //]),

            Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /// todo: this needs to be the blockchain of the address not the holding
                      /// of course it should always be the same so validate it
                      CurrencyIdenticon(
                        holding: cubits.holding.state.holding,
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                          child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: SelectableText.rich(
                          TextSpan(
                            text: '',
                            style: AppText.body1,
                            children: <TextSpan>[
                              TextSpan(
                                text: cubits.send.state.sendRequest!.sendAddress
                                    .substring(0, 6),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: cubits.send.state.sendRequest!.sendAddress
                                    .substring(
                                        6,
                                        cubits.send.state.sendRequest!
                                                .sendAddress.length -
                                            6),
                              ),
                              TextSpan(
                                text: cubits.send.state.sendRequest!.sendAddress
                                    .substring(cubits.send.state.sendRequest!
                                            .sendAddress.length -
                                        6),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: ConfirmationItem(
                    label: 'Fee:',
                    overrideDisplay: SimpleCoinSplitView(
                        mode: DifficultyMode.hard,
                        coin: Sats(cubits.send.state.estimate!.fees).toCoin(),
                        incoming: null))),
            if (cubits.send.state.unsignedTransaction!.security.isCoin) ...[
              const Divider(height: 1, indent: 0, endIndent: 0),
              Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: ConfirmationItem(
                      label: 'Total:',
                      overrideDisplay: SimpleCoinSplitView(
                          mode: DifficultyMode.hard,
                          coin:
                              Sats(cubits.send.state.estimate!.total).toCoin(),
                          incoming: null))),
            ] else if (cubits
                .send.state.unsignedTransaction!.security.isAsset) ...[
              const Divider(height: 1, indent: 0, endIndent: 0),
              Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: ConfirmationItem(
                      label: 'Amount:',
                      overrideDisplay: SimpleCoinSplitView(
                          mode: DifficultyMode.hard,
                          coin:
                              Sats(cubits.send.state.estimate!.amount).toCoin(),
                          incoming: null))),
            ],
            const SizedBox(height: 8),
            Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 12, bottom: 24),
                child: GestureDetector(
                    onTap: _send,
                    child: Container(
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.button,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                            child: Text(
                          'SEND',
                          style: AppText.button1
                              .copyWith(fontSize: 16, color: Colors.white),
                        ))))),
          ],
        ),
      );
}

class ConfirmationItem extends StatelessWidget {
  final String label;
  final List<TextSpan> display;
  final Widget? overrideDisplay;
  const ConfirmationItem({
    super.key,
    required this.label,
    this.display = const <TextSpan>[],
    this.overrideDisplay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        //color: Colors.red,
        width: screen.width,
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.body1),
            if (overrideDisplay != null)
              overrideDisplay!
            else
              RichText(
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                text: TextSpan(
                  style:
                      Theme.of(context).textTheme.body1, // Default text style
                  children: display,
                ),
              )
          ],
        ));
  }
}
