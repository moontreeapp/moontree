import 'package:flutter/material.dart';
import 'package:ravencoin_back/server/src/protocol/comm_transaction_view.dart';
import 'package:ravencoin_back/services/transaction/transaction.dart';
import 'package:ravencoin_front/cubits/cubits.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet_utils/src/utilities/validation_ext.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/utils/extensions.dart';
import 'package:ravencoin_front/services/storage.dart';
import 'package:ravencoin_front/widgets/back/coinspec/spec.dart';
import 'package:ravencoin_front/widgets/back/coinspec/tabs.dart';
import 'package:ravencoin_front/widgets/backdrop/curve.dart';
import 'package:ravencoin_front/widgets/bottom/navbar.dart';
import 'package:ravencoin_front/widgets/front/lists/transactions.dart';
import 'package:ravencoin_front/pages/wallet/transactions/components.dart'
    show MetaDataWidget, AssetNavbar, CoinDetailsHeader;

//class AssetNavbar extends StatelessWidget {
//  const AssetNavbar({Key? key}) : super(key: key);
//
//  @override
//  Widget build(BuildContext context) {
//    return NavBar(
//      includeSectors: false,
//      actionButtons: <Widget>[
//        components.buttons.actionButton(
//          context,
//          label: 'send',
//          link: '/transaction/send',
//        ),
//        components.buttons.actionButton(
//          context,
//          label: 'receive',
//          link: '/transaction/receive',
//          arguments: transactionsBloc.security != pros.securities.currentCoin
//              ? <String, dynamic>{'symbol': transactionsBloc.security.symbol}
//              : null,
//        )
//      ],
//    );
//  }
//}

class AssetDetailsContent extends StatelessWidget {
  const AssetDetailsContent(
    this.cubit,
    this.cachedMetadataView,
    this.scrollController, {
    Key? key,
  }) : super(key: key);
  final TransactionsViewCubit cubit;
  final Widget? cachedMetadataView;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
        stream: cubit.state.currentTab,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          final String tab = snapshot.data ?? 'HISTORY';
          final bool showTransactions = tab == CoinSpecTabs.tabIndex[0];
          return showTransactions
              ? TransactionList(
                  scrollController: scrollController,
                  symbol: cubit.state.security.symbol,
                  transactions: cubit.state.transactionViews
                      as Iterable<TransactionView>?,
                  msg: '\nNo ${cubit.state.security.symbol} transactions.\n')
              : MetaDataWidget(cachedMetadataView);
        });
  }
}
