import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/cubit.dart';
import 'package:moontree/cubits/cubits.dart';
import 'package:moontree/presentation/ui/wallet/transactions/feed/page.dart';
import 'package:moontree/services/services.dart';

class WalletFeedPage extends StatelessWidget {
  const WalletFeedPage({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<WalletFeedCubit, WalletFeedState>(
          builder: (BuildContext context, WalletFeedState state) =>
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: 100,
                  itemBuilder: (context, index) => ListTile(
                        onTap: () {
                          // move to maestro
                          cubits.walletLayer.update(active: false);
                          //cubits.pane.removeChild();
                          cubits.pane.update(height: screen.pane.midHeight);
                          cubits.transactionsLayer.update(active: true);
                          cubits.pane.update(
                              scrollableChild: (ScrollController scroller) =>
                                  TransactionsFeedPage(scroller: scroller));
                        },
                        title: Text('Item $index',
                            style: const TextStyle(color: Colors.grey)),
                      )));
}
