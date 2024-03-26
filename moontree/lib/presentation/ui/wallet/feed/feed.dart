import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/cubit.dart';
import 'package:moontree/cubits/wallet/feed/cubit.dart';
import 'package:moontree/presentation/ui/wallet/feed/page.dart';

class WalletFeedLayer extends StatelessWidget {
  final ScrollController scrollController;
  const WalletFeedLayer({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<WalletFeedCubit, WalletFeedState>(
          builder: (BuildContext context, WalletFeedState state) {
        if (state.active) {
          if (state.currency.isEmpty && state.assets.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback(
                (_) => cubits.walletFeed.populateAssets());
            return const Center(
                child:
                    Text('Loading...', style: TextStyle(color: Colors.grey)));
          }
          return WalletFeedPage(scrollController: scrollController);
        }
        //cubits.pane.update(child: const WalletFeedPage());
        return const SizedBox.shrink();
      });
}
