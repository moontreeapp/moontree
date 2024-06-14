import 'package:flutter/material.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/presentation/theme/colors.dart';
import 'package:magic/presentation/theme/extensions.dart';
import 'package:magic/presentation/theme/text.dart';
import 'package:magic/presentation/ui/pane/wallet/page.dart';
import 'package:magic/services/services.dart';

class ConfirmContent extends StatelessWidget {
  const ConfirmContent({super.key});

  void _send() {
    // sign it.
    // broadcast it.
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
                      CurrencyIdenticon(holding: cubits.holding.state.holding),
                      const SizedBox(width: 8),
                      const Text(
                        'address',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: ConfirmationItem(label: 'Fee:', display: <TextSpan>[
                  TextSpan(
                      text: 'display.coin.whole()',
                      style: Theme.of(context).textTheme.body1.copyWith(
                            fontWeight: FontWeight.normal,
                            color: AppColors.black87,
                          )),
                  TextSpan(
                      text: 'display.coin.spacedPart()',
                      style: Theme.of(context).textTheme.body1.copyWith(
                          fontWeight: FontWeight.normal,
                          color: AppColors.black60,
                          fontSize: 12)),
                ])),
            const Divider(height: 1, indent: 0, endIndent: 0),
            Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: ConfirmationItem(label: 'Total:', display: <TextSpan>[
                  TextSpan(
                      text: 'amount+fee',
                      style: Theme.of(context).textTheme.body1.copyWith(
                            fontWeight: FontWeight.normal,
                            color: AppColors.black87,
                          )),
                  TextSpan(
                      text: '.conform to design',
                      style: Theme.of(context).textTheme.body1.copyWith(
                          fontWeight: FontWeight.normal,
                          color: AppColors.black60,
                          fontSize: 12)),
                ])),
            const SizedBox(height: 8),
            Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 12, bottom: 24),
                child: GestureDetector(
                    onTap: _send,
                    child: Container(
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: AppColors.successDark,
                            width: 4,
                          ),
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
    required this.display,
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
