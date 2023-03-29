import 'dart:async';
import 'dart:math';
import 'dart:io' show Platform;
import 'package:client_back/server/src/protocol/comm_balance_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as flutter_bloc;
import 'package:client_back/client_back.dart';
import 'package:client_front/application/cubits.dart';
import 'package:client_front/presentation/pagesv1/wallet/transactions/components.dart';
import 'package:client_front/domain/utils/data.dart';
import 'package:client_front/domain/utils/extensions.dart';
import 'package:client_front/presentation/widgets/widgets.dart';
import 'package:client_front/presentation/widgets/backdrop/backdrop.dart';
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
  int lengthOfLoadMore = 0;
  double currentMaxScroll = 0;
  double previousMaxScroll = 0;
  bool timedCalling = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TransactionsViewCubit cubit =
        flutter_bloc.BlocProvider.of<TransactionsViewCubit>(context);
    data = populateData(context, data);
    final balanceView = (data['holding'] as BalanceView?)!;
    // first set the wallet and security so we can set the coinspec
    cubit.set(
        wallet: pros.wallets.currentWallet,
        security: Security(
          symbol: balanceView.symbol,
          chain: pros.settings.chain,
          net: pros.settings.net,
        ));
    // then get the transactions from the future endpoint call
    if (!pros.wallets.currentWallet.minerMode) {
      cubit.setInitial();
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
                  cubit,
                  state.security,
                  minHeight,
                  cubit.nullCacheView,
                  balanceView: balanceView,
                ),
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
                            try {
                              state.scrollObserver.add(dController.size);
                            } catch (e) {
                              return;
                            }
                          }

                          scrollController.addListener(() async {
                            /// just call this as soon as we start scrolling
                            /// actually thats not efficient for the server
                            double maxScroll =
                                scrollController.position.maxScrollExtent;
                            if (currentMaxScroll < maxScroll) {
                              previousMaxScroll = currentMaxScroll;
                              currentMaxScroll = maxScroll;
                            }
                            double currentScroll =
                                scrollController.position.pixels;
                            if (currentScroll > previousMaxScroll) {
                              if (lengthOfLoadMore <
                                  state.transactionViews.length) {
                                lengthOfLoadMore =
                                    state.transactionViews.length;
                                await cubit.addSetTransactionViews();
                              }
                            }
                            if (currentScroll == maxScroll) {
                              // first time we hit the bottom, set a timer
                              if (!timedCalling) {
                                timedCalling = true;
                                await Future.delayed(
                                  Duration(seconds: 5),
                                  () async {
                                    // if max hasn't changed after 5 seconds
                                    if (mounted &&
                                        maxScroll ==
                                            scrollController
                                                .position.maxScrollExtent) {
                                      // call it again
                                      await cubit.addSetTransactionViews(
                                          force: true);
                                    }
                                  },
                                ).then((value) => timedCalling = false);
                              }

                              //if (lengthOfLoadMore <
                              //    state.transactionViews.length) {
                              //  print('length');
                              //  lengthOfLoadMore =
                              //      state.transactionViews.length;
                              //  await cubit.addSetTransactionViews();
                              //}
                            }
                          });
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
