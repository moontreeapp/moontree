// import 'package:flutter/material.dart';
// import 'package:magic/presentation/theme/colors.dart';
// import 'package:magic/presentation/theme/text.dart';
// import 'package:magic/presentation/widgets/other/other.dart';
// import 'package:magic/services/services.dart';
//
// class TransactionPage extends StatelessWidget {
//   const TransactionPage({super.key});
//
//   @override
//   Widget build(BuildContext context) => Container(
//       height: screen.pane.midHeight,
//       padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 24),
//       child:
//           Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//         const Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             TextFieldFormatted(
//               autocorrect: false,
//               textInputAction: TextInputAction.next,
//               labelText: 'To',
//               suffixIcon: Icon(Icons.qr_code_scanner, color: AppColors.black60),
//             ),
//             SizedBox(height: 4),
//             TextFieldFormatted(
//               autocorrect: false,
//               textInputAction: TextInputAction.done,
//               labelText: 'Amount',
//             ),
//           ],
//         ),
//         Container(
//             height: 64,
//             decoration: ShapeDecoration(
//               color: AppColors.error,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(28 * 100),
//               ),
//             ),
//             child: Center(
//                 child: Text(
//               'SEND',
//               style: AppText.button1.copyWith(color: Colors.white),
//             ))),
//       ]));
// }
//
//
// /// how to use scroll view
// //CustomScrollView(
// //    shrinkWrap: true,
// //    slivers: <Widget>[
// //  SliverToBoxAdapter(
// //    child: Column(
// //  SliverFillRemaining(
// //    hasScrollBody: false,
// //    child: Column(

import 'package:flutter/material.dart';
import 'package:lit_relative_date_time/controller/relative_date_format.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/domain/concepts/numbers/coin.dart';
import 'package:magic/domain/concepts/numbers/sats.dart';
import 'package:magic/domain/concepts/transaction.dart';
import 'package:magic/presentation/theme/theme.dart';
import 'package:magic/services/services.dart';

class TransactionPage extends StatelessWidget {
  const TransactionPage({super.key});

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: ListView(
          controller: cubits.pane.state.scroller,
          shrinkWrap: true,
          children: [
            TransactionItem(
                label: 'To:',
                // point to cubit.transaction
                display: TransactionDisplay(
                    incoming: true,
                    sats:
                        Sats.fromCoin(Coin(coin: 20000000000, sats: 10000001)),
                    when: DateTime.now())),
            //TransactionItem(
            //    label: 'Amount:',
            //    display: TransactionDisplay(
            //        incoming: true,
            //        sats: Sats.fromCoin(Coin(20 000 000 000.10000001)),
            //        when: DateTime.now())),
            //TransactionItem(
            //    label: 'Date:',
            //    display: TransactionDisplay(
            //        incoming: true,
            //        sats: Sats.fromCoin(Coin(20000000000.10000001)),
            //        when: DateTime.now())),
            //TransactionItem(
            //    label: 'Time:',
            //    display: TransactionDisplay(
            //        incoming: true,
            //        sats: Sats.fromCoin(Coin(20000000000.10000001)),
            //        when: DateTime.now())),
          ]));
}

class TransactionItem extends StatelessWidget {
  final String label;
  final TransactionDisplay display;
  const TransactionItem(
      {super.key, required this.label, required this.display});

  @override
  Widget build(BuildContext context) {
    /// maybe this should be created once in a service...
    RelativeDateFormat relativeDateFormatter = RelativeDateFormat(
      Localizations.localeOf(context),
    );
    print('display.sats.value: ${display.sats.value}');
    print('sats should be    : 2000000000010000001');
    print('display.coin.value: ${display.coin.humanString()}');
    print('coin should be    : 20000000000.10000001');
    return GestureDetector(
        onTap: () => maestro.activateTransaction(display),
        child: Container(
            alignment: Alignment.center,
            //color: Colors.red,
            width: screen.width,
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: Theme.of(context).textTheme.body1),
                RichText(
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  text: TextSpan(
                    style:
                        Theme.of(context).textTheme.body1, // Default text style
                    children: <TextSpan>[
                      TextSpan(
                          text:
                              '${display.incoming ? '+' : '-'}${display.coin.whole()}',
                          style: Theme.of(context).textTheme.body1.copyWith(
                                fontWeight: FontWeight.normal,
                                color: AppColors.black87,
                              )),
                      TextSpan(
                          text: display.coin.part(),
                          style: Theme.of(context).textTheme.body1.copyWith(
                              fontWeight: FontWeight.normal,
                              color: AppColors.black60,
                              fontSize: 12)),
                    ],
                  ),
                )
              ],
            )));
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
    //                      color: AppColors.black87,
    //                    )),
    //            TextSpan(
    //                text: display.coin.part(),
    //                style: Theme.of(context).textTheme.body1.copyWith(
    //                    fontWeight: FontWeight.normal,
    //                    color: AppColors.black60,
    //                    fontSize: 12)),
    //          ],
    //        ),
    //      )
    //      //child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
    //      //  Text(
    //      //      '${display.incoming ? '+' : '-'}${display.sats.toCoin.whole()}',
    //      //      style: Theme.of(context).textTheme.body1.copyWith(
    //      //            fontWeight: FontWeight.w300,
    //      //            color: AppColors.black87,
    //      //          )),
    //      //  Text(display.sats.toCoin.whole(),
    //      //      overflow: TextOverflow.ellipsis,
    //      //      style: Theme.of(context).textTheme.body1.copyWith(
    //      //            fontWeight: FontWeight.w300,
    //      //            color: AppColors.black60,
    //      //          ))
    //      //])
    //      ),
    //);
  }
}
