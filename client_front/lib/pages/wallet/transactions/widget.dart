import 'dart:math';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as flutter_bloc;
import 'package:client_back/client_back.dart';
import 'package:client_front/cubits/cubits.dart';
import 'package:client_front/pages/wallet/transactions/components.dart';
import 'package:client_front/utils/data.dart';
import 'package:client_front/utils/extensions.dart';
import 'package:client_front/widgets/widgets.dart';

//import 'bloc.dart';

double minHeight = 0.65.figmaAppHeight;

class Transactions extends StatefulWidget {
  const Transactions({Key? key}) : super(key: key);

  @override
  _TransactionsState createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  Map<String, dynamic> data = <String, dynamic>{};
  DraggableScrollableController dController = DraggableScrollableController();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TransactionsViewCubit cubit =
        flutter_bloc.BlocProvider.of<TransactionsViewCubit>(context);
    data = populateData(context, data);
    // first set the wallet and security so we can set the coinspec
    cubit.set(
        wallet: pros.wallets.currentWallet,
        security: (data['holding'] as Balance?)?.security);
    // then get the transactions from the future endpoint call
    if (!pros.wallets.currentWallet.minerMode) {
      cubit.setTransactionViews();
    }
    minHeight = !Platform.isIOS
        ? 0.65.figmaAppHeight + (cubit.nullCacheView ? 0 : 48.ofAppHeight)
        : 0.63.figmaAppHeight + (cubit.nullCacheView ? 0 : 48.ofAppHeight);
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: flutter_bloc.BlocBuilder<TransactionsViewCubit,
                TransactionsViewState>(
            bloc: cubit..enter(),
            builder: (BuildContext context, TransactionsViewState state) {
              return BackdropLayers(
                back: CoinDetailsHeader(
                    cubit, state.security, minHeight, cubit.nullCacheView),
                front: Stack(
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    DraggableScrollableSheet(
                        initialChildSize: minHeight,
                        minChildSize: minHeight,
                        maxChildSize: min(
                            1.0,
                            max(
                                minHeight,
                                getMaxExtent(
                                    context, state.transactionViews.length))),
                        controller: dController,
                        builder: (BuildContext context,
                            ScrollController scrollController) {
                          //bloc.scrollObserver.add(dController.size);
                          _scrollListener() {
                            state.scrollObserver.add(dController.size);
                          }

                          dController.addListener(_scrollListener);
                          return CoinDetailsGlidingSheet(
                            cubit: cubit,
                            cachedMetadataView: cubit.nullCacheView
                                ? null
                                : MetadataView(cubit: cubit),
                            dController: dController,
                            scrollController: scrollController,
                          );
                        }),
                    AssetNavbar(cubit: cubit)
                  ],
                ),
              );
            }));
  }

  double getMaxExtent(BuildContext context, int itemLength) {
    return (itemLength * 80 + 80 + 40 + 80).ofMediaHeight(context);
  }
}
