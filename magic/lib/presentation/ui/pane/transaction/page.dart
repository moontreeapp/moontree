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
import 'package:magic/cubits/cubit.dart';
import 'package:magic/domain/concepts/transaction.dart';
import 'package:magic/presentation/theme/theme.dart';
import 'package:magic/services/services.dart';

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
                TransactionItem(label: 'Amount:', display: <TextSpan>[
                  TextSpan(
                      text:
                          '${display.incoming ? '+' : '-'}${display.coin.whole()}',
                      style: Theme.of(context).textTheme.body1.copyWith(
                            fontWeight: FontWeight.normal,
                            color: AppColors.black87,
                          )),
                  TextSpan(
                      text: display.coin.spacedPart(),
                      style: Theme.of(context).textTheme.body1.copyWith(
                          fontWeight: FontWeight.normal,
                          color: AppColors.black60,
                          fontSize: 12)),
                ]),
                TransactionItem(label: 'Date:', display: <TextSpan>[
                  TextSpan(
                      text: display.humanDate(),
                      style: Theme.of(context).textTheme.body1.copyWith(
                            fontWeight: FontWeight.normal,
                            color: AppColors.black87,
                          )),
                ]),
                TransactionItem(label: 'Time:', display: <TextSpan>[
                  TextSpan(
                      text: display.humanTime(),
                      style: Theme.of(context).textTheme.body1.copyWith(
                            fontWeight: FontWeight.normal,
                            color: AppColors.black87,
                          )),
                ])
              ]),
              Container(
                  height: 64,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28 * 100),
                    ),
                  ),
                  child: Center(
                      child: Text(
                    'View Details',
                    style: AppText.button1.copyWith(color: AppColors.success),
                  ))),
            ]));
  }
}

class TransactionItem extends StatelessWidget {
  final String label;
  final List<TextSpan> display;
  const TransactionItem(
      {super.key, required this.label, required this.display});

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
            RichText(
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              text: TextSpan(
                style: Theme.of(context).textTheme.body1, // Default text style
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
