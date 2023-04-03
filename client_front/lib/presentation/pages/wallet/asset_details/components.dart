import 'package:flutter/material.dart';
import 'package:client_back/server/src/protocol/comm_transaction_view.dart';
import 'package:client_back/services/transaction/transaction.dart';
import 'package:client_front/application/cubits.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet_utils/src/utilities/validation_ext.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/presentation/components/components.dart';
import 'package:client_front/domain/utils/extensions.dart';
import 'package:client_front/infrastructure/services/storage.dart';
import 'package:client_front/presentation/widgets/back/coinspec/spec.dart';
import 'package:client_front/presentation/widgets/back/coinspec/tabs.dart';
import 'package:client_front/presentation/widgets/backdrop/curve.dart';
import 'package:client_front/presentation/widgets/bottom/navbar.dart';
import 'package:client_front/presentation/widgets/front/lists/transactions.dart';
import 'package:client_front/presentation/pages/wallet/transactions/components.dart'
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
                  cubit: cubit,
                  scrollController: scrollController,
                  symbol: cubit.state.security.symbol,
                  transactions: cubit.state.transactionViews,
                  msg: '\nNo ${cubit.state.security.symbol} transactions.\n')
              : MetaDataWidget(cachedMetadataView);
        });
  }
}
