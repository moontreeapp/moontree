import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/cubit.dart';
import 'package:moontree/cubits/wallet/transactions/feed/cubit.dart';
import 'package:moontree/presentation/ui/wallet/transactions/feed/page.dart';

class TransactionsFeedLayer extends StatelessWidget {
  const TransactionsFeedLayer({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<TransactionsFeedCubit, TransactionsFeedState>(
          builder: (BuildContext context, TransactionsFeedState state) {
        if (state.currency.isEmpty && state.assets.isEmpty) {
          cubits.walletFeed.populateAssets();
          return const Center(
              child: Text('Loading...', style: TextStyle(color: Colors.grey)));
        }
        //return TransactionsFeedPage();
        //cubits.pane.update(
        //    scrollableChild: (ScrollController scroller) =>
        //        TransactionsFeedPage(scroller: scroller));
        return const SizedBox.shrink();
      });
}
