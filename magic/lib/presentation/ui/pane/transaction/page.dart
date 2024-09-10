import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:magic/cubits/canvas/oldmenu/cubit.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/toast/cubit.dart';
import 'package:magic/domain/concepts/transaction.dart';
import 'package:magic/presentation/theme/theme.dart';
import 'package:magic/presentation/widgets/assets/amounts.dart';
import 'package:magic/services/services.dart';
import 'package:url_launcher/url_launcher.dart';

class TransactionPage extends StatelessWidget {
  const TransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (cubits.holding.state.transaction == null) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text('No Transaction Data to Display.')],
      );
    }

    final TransactionDisplay display = cubits.holding.state.transaction!;
    return Container(
        height: screen.pane.midHeight,
        padding:
            const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 24),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                //if (![null, '']
                //    .contains(display.transactionView?.hash.toString()))
                GestureDetector(
                    onLongPress: () {
                      Clipboard.setData(ClipboardData(text: display.hash));
                      cubits.toast.flash(
                          msg: const ToastMessage(
                              duration: Duration(seconds: 2),
                              title: 'copied',
                              text: 'to clipboard'));
                    },
                    child: TransactionItem(label: 'ID:', display: <TextSpan>[
                      TextSpan(
                          text: display.readableHash,
                          style: Theme.of(context).textTheme.body1.copyWith(
                                fontWeight: FontWeight.normal,
                                color: AppColors.white87,
                              )),
                    ])),
                TransactionItem(
                    label: 'Amount:',
                    overrideDisplay: SimpleCoinSplitView(
                        mode: DifficultyMode.hard,
                        coin: display.sats.toCoin(),
                        incoming: display.incoming),
                    display: <TextSpan>[
                      TextSpan(
                          text:
                              '${display.incoming ? '+' : '-'}${display.coin.whole()}',
                          style: Theme.of(context).textTheme.body1.copyWith(
                                fontWeight: FontWeight.normal,
                                color: AppColors.white87,
                              )),
                      TextSpan(
                          text: display.coin.spacedPart(),
                          style: Theme.of(context).textTheme.body1.copyWith(
                              fontWeight: FontWeight.normal,
                              color: AppColors.white60,
                              fontSize: 12)),
                    ]),
                TransactionItem(label: 'Date:', display: <TextSpan>[
                  TextSpan(
                      text: display.humanDate(),
                      style: Theme.of(context).textTheme.body1.copyWith(
                            fontWeight: FontWeight.normal,
                            color: AppColors.white87,
                          )),
                ]),
                TransactionItem(label: 'Time:', display: <TextSpan>[
                  TextSpan(
                      text: display.humanTime(),
                      style: Theme.of(context).textTheme.body1.copyWith(
                            fontWeight: FontWeight.normal,
                            color: AppColors.white87,
                          )),
                ])
              ]),
              ElevatedButton(
                  onPressed: () => launchUrl(Uri.parse(
                      display.blockchain?.explorerTxUrl(display.hash) ?? '')),
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all<Color>(AppColors.front),
                    foregroundColor:
                        WidgetStateProperty.all<Color>(AppColors.front),
                    shadowColor:
                        WidgetStateProperty.all<Color>(Colors.transparent),
                    elevation: WidgetStateProperty.all<double>(0),
                    overlayColor: WidgetStateProperty.all<Color>(
                        AppColors.white.withOpacity(0.12)),
                  ),
                  child: Container(
                      height: 64,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28 * 100),
                        ),
                      ),
                      child: Center(
                          child: Text(
                        'VIEW DETAILS',
                        style: AppText.button1.copyWith(
                            color: AppColors.white38,
                            fontWeight: FontWeight.bold),
                      )))),
              //GestureDetector(
              //    onTap: () => launchUrl(Uri.parse(
              //        display.blockchain?.explorerTxUrl(display.hash) ?? '')),
              //    child: Container(
              //        height: 64,
              //        decoration: ShapeDecoration(
              //          shape: RoundedRectangleBorder(
              //            borderRadius: BorderRadius.circular(28 * 100),
              //          ),
              //        ),
              //        child: Center(
              //            child: Text(
              //          'VIEW DETAILS',
              //          style: AppText.button1.copyWith(
              //              color: AppColors.success,
              //              fontWeight: FontWeight.bold),
              //        )))),
              //Material(
              //  color: Colors.transparent,
              //  child: InkWell(
              //    borderRadius: BorderRadius.circular(28 * 100),
              //    splashColor: AppColors.background.withOpacity(0.2),
              //    onTap: () => launchUrl(Uri.parse(
              //        display.blockchain?.explorerTxUrl(display.hash) ?? '')),
              //    child: Container(
              //      height: 64,
              //      decoration: ShapeDecoration(
              //        shape: RoundedRectangleBorder(
              //          borderRadius: BorderRadius.circular(28 * 100),
              //        ),
              //      ),
              //      child: Center(
              //        child: Text(
              //          'VIEW DETAILS',
              //          style: AppText.button1.copyWith(
              //            color: AppColors.success,
              //            fontWeight: FontWeight.bold,
              //          ),
              //        ),
              //      ),
              //    ),
              //  ),
              //),
            ]));
  }
}

class TransactionItem extends StatelessWidget {
  final String label;
  final List<TextSpan> display;
  final Widget? overrideDisplay;
  const TransactionItem({
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
    //return ListTile(
    //  //dense: true,
    //  //visualDensity: VisualDensity.compact,
    //  onTap: () => maestro.activateTransaction(display),
    //  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    //  title: Text(display.humanWhen(relativeDateFormatter),
    //      style: Theme.of(context).textTheme.body1),
    //  trailing: SizedBox(
    //      width: screen.width,
    //      child: RichText(
    //        textAlign: TextAlign.end,
    //        overflow: TextOverflow.ellipsis,
    //        softWrap: false,
    //        text: TextSpan(
    //          style: Theme.of(context).textTheme.body1, // Default text style
    //          children: <TextSpan>[
    //            TextSpan(
    //                text:
    //                    '${display.incoming ? '+' : '-'}${display.coin.whole()}',
    //                style: Theme.of(context).textTheme.body1.copyWith(
    //                      fontWeight: FontWeight.normal,
    //                      color: AppColors.white87,
    //                    )),
    //            TextSpan(
    //                text: display.coin.part(),
    //                style: Theme.of(context).textTheme.body1.copyWith(
    //                    fontWeight: FontWeight.normal,
    //                    color: AppColors.white60,
    //                    fontSize: 12)),
    //          ],
    //        ),
    //      )
    //      //child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
    //      //  Text(
    //      //      '${display.incoming ? '+' : '-'}${display.sats.toCoin.whole()}',
    //      //      style: Theme.of(context).textTheme.body1.copyWith(
    //      //            fontWeight: FontWeight.w300,
    //      //            color: AppColors.white87,
    //      //          )),
    //      //  Text(display.sats.toCoin.whole(),
    //      //      overflow: TextOverflow.ellipsis,
    //      //      style: Theme.of(context).textTheme.body1.copyWith(
    //      //            fontWeight: FontWeight.w300,
    //      //            color: AppColors.white60,
    //      //          ))
    //      //])
    //      ),
    //);
  }
}
