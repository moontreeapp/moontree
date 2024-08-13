import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lit_relative_date_time/lit_relative_date_time.dart';
import 'package:magic/cubits/canvas/menu/cubit.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/pane/transactions/cubit.dart';
import 'package:magic/domain/concepts/transaction.dart';
import 'package:magic/presentation/ui/pane/receive/page.dart';
import 'package:magic/presentation/utils/animation.dart';
import 'package:magic/presentation/widgets/animations/fading.dart';
import 'package:magic/presentation/widgets/animations/loading.dart';
import 'package:magic/presentation/widgets/assets/amounts.dart';
import 'package:magic/services/services.dart' show maestro, screen;
import 'package:magic/presentation/theme/theme.dart';
import 'package:magic/presentation/widgets/assets/icons.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<TransactionsCubit, TransactionsState>(
          buildWhen: (previous, current) =>
              previous.transactions.length != current.transactions.length ||
              previous.mempool.length != current.mempool.length ||
              previous.clearing != current.clearing ||
              previous.isSubmitting != current.isSubmitting,
          builder: (BuildContext context, TransactionsState state) {
            if (state.isSubmitting) {
              return const LoadingIndicator();
            }
            if (state.transactions.isEmpty && state.mempool.isEmpty) {
              // shimmer until transactions are fetched
              return FadeIn(
                  delay: slowFadeDuration + fadeDuration,
                  child: const SoftReceivePage());
            }

            ///BlocBuilder<HoldingCubit, HoldingState>(
            ///    buildWhen: (HoldingState previous, HoldingState current) =>
            ///        previous.holding != current.holding,
            ///    builder: (context, HoldingState holdingState) =>
            final mempool = cubits.transactions.state.mempool;
            final transactions = cubits.transactions.state.transactions;
            return AnimatedOpacity(
                duration: fastFadeDuration,
                opacity: state.clearing ? 0 : 1,
                child: RefreshIndicator(
                    onRefresh: () async {
                      print('refreshing transactions');
                      return cubits.transactions.populateAllTransactions();
                    },
                    child: ListView.builder(
                        controller: cubits.pane.state.scroller,
                        shrinkWrap: true,
                        itemCount: mempool.length + transactions.length,
                        itemBuilder: (context, index) => TransactionItem(
                            display: index < mempool.length
                                ? mempool.elementAt(index)
                                : transactions
                                    .elementAt(index - mempool.length)))));
          });
}

class TransactionItem extends StatelessWidget {
  final TransactionDisplay display;
  const TransactionItem({super.key, required this.display});

  @override
  Widget build(BuildContext context) {
    RelativeDateFormat relativeDateFormatter = RelativeDateFormat(
      Localizations.localeOf(context),
    );
    return ListTile(
        //dense: true,
        //visualDensity: VisualDensity.compact,
        onTap: () => maestro.activateTransaction(display),
        splashColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: screen.iconHuge,
          height: screen.iconHuge,
          //color: Colors.red,
          alignment: Alignment.center,
          child: SvgPicture.asset(
            '${TransactionIcons.base}/${display.incoming ? 'incoming' : 'outgoing'}.${TransactionIcons.ext}',
            height: screen.iconHuge,
            width: screen.iconHuge,
            fit: BoxFit.contain,
            colorFilter: const ColorFilter.mode(
                AppColors.frontHighlight, BlendMode.srcIn),
            alignment: Alignment.center,
          ),
        ),
        title: SizedBox(
            width: screen.width - (16 + 16 + screen.iconLarge + 16),
            child: Text(display.humanWhen(relativeDateFormatter),
                style: Theme.of(context).textTheme.body1.copyWith(
                      height: 0,
                      color: AppColors.white60,
                    ))),
        //trailing: SizedBox(
        //    //width: screen.width - (16 + 16 + screen.iconLarge + 16),
        //    child: Text(
        //        '${display.incoming ? '+' : '-'}${display.sats.toCoin().humanString()}',
        //        style: Theme.of(context).textTheme.body1.copyWith(
        //              height: 0,
        //              color:
        //                  display.incoming ? AppColors.success : AppColors.black,
        //             ))),
        trailing: display.sats.toCoin().whole() == '0' &&
                display.sats.toCoin().boldedPart().isEmpty
            ? Text('Sent to Self',
                style: Theme.of(context).textTheme.body1.copyWith(
                      height: 0,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white.withOpacity(.67),
                    ))
            : SimpleCoinSplitView(
                mode: DifficultyMode.hard,
                coin: display.sats.toCoin(),
                incoming: display.incoming)
        //CoinSplitView(display: display, coin: display.sats.toCoin())
        //trailing: CoinView(
        //    coin: display.sats.toCoin(),
        //    wholeStyle: Theme.of(context)
        //        .textTheme
        //        .body1
        //        .copyWith(height: 0, color: AppColors.white60),
        //    partOneStyle: Theme.of(context)
        //        .textTheme
        //        .body1
        //        .copyWith(height: 0, fontSize: 14, color: AppColors.white60),
        //    partTwoStyle: Theme.of(context)
        //        .textTheme
        //        .body1
        //        .copyWith(height: 0, fontSize: 10, color: AppColors.white60),
        //    partThreeStyle: Theme.of(context)
        //        .textTheme
        //        .body1
        //        .copyWith(height: 0, fontSize: 10, color: AppColors.white60),
        //    mode: DifficultyMode.hard)
        );
  }
}
