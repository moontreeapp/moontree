import 'package:flutter/material.dart';
import 'package:raven/raven.dart';
import 'package:raven/services/transaction.dart';
import 'package:raven_mobile/components/components.dart';
import 'package:raven_mobile/theme/extensions.dart';

class ListComponents {
  ListComponents();

  Container transactionsView(
    BuildContext context, {
    required Iterable<TransactionRecord> transactions,
    required bool showUSD,
    Function? onLongPress,
    String? msg,
  }) =>
      transactions.isEmpty
          ? _emptyMessage(
              context,
              icon: Icons.public,
              msg: msg ?? '\nYour transactions will appear here.\n',
            )
          : Container(
              alignment: Alignment.center,
              child: _transactionsView(
                context,
                transactions: transactions,
                showUSD: showUSD,
                onLongPress: onLongPress,
              ));

  Container holdingsView(
    BuildContext context, {
    required Iterable<Balance> holdings,
    required bool showUSD,
    Function? onLongPress,
    Wallet? wallet,
    String? msg,
  }) =>
      holdings.isEmpty
          ? _emptyMessage(
              context,
              icon: Icons.savings,
              msg: msg ?? '\nYour holdings will appear here.\n',
            )
          : Container(
              alignment: Alignment.center,
              child: _holdingsView(
                context,
                holdings: holdings,
                showUSD: showUSD,
                onLongPress: onLongPress,
                wallet: wallet,
              ));

  Container emptyMessage(
    BuildContext context, {
    required String msg,
    IconData? icon,
  }) =>
      _emptyMessage(
        context,
        icon: Icons.savings,
        msg: msg,
      );

  static ListView _transactionsView(
    BuildContext context, {
    required Iterable<TransactionRecord> transactions,
    required bool showUSD,
    Function? onLongPress,
  }) =>
      ListView(children: <Widget>[
        for (var transactionRecord in transactions) ...[
          ListTile(
            onTap: () => Navigator.pushNamed(context, '/transaction',
                arguments: {'transactionRecord': transactionRecord}),
            onLongPress: onLongPress != null ? () => onLongPress() : () {},
            leading: Container(
                height: 50,
                width: 50,
                child: components.icons
                    .assetAvatar(transactionRecord.security.symbol)),
            title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(transactionRecord.security.symbol,
                            style: Theme.of(context).textTheme.bodyText2),
                        Text(transactionRecord.formattedDatetime,
                            style: Theme.of(context).annotate),
                      ]),
                  (transactionRecord.out
                      ? components.icons.out(context)
                      : components.icons.income(context)),
                ]),
            trailing: (transactionRecord.out
                ? Text(
                    components.text.securityAsReadable(transactionRecord.value,
                        security: transactionRecord.security, asUSD: showUSD),
                    style: TextStyle(color: Theme.of(context).bad))
                : Text(
                    components.text.securityAsReadable(transactionRecord.value,
                        security: transactionRecord.security, asUSD: showUSD),
                    style: TextStyle(color: Theme.of(context).good))),
          )
        ]
      ]);

  static ListView _holdingsView(
    BuildContext context, {
    required Iterable<Balance> holdings,
    required bool showUSD,
    Function? onLongPress,
    Wallet? wallet,
  }) {
    var rvnHolding = <Widget>[];
    var assetHoldings = <Widget>[];
    for (var holding in holdings) {
      var thisHolding = ListTile(
          onTap: () => Navigator.pushNamed(context,
              holding.security.symbol == 'RVN' ? '/transactions' : '/asset',
              arguments: {'holding': holding, 'walletId': wallet?.walletId ?? null}),
          onLongPress: onLongPress != null ? () => onLongPress() : () {},
          leading: Container(
              height: 50,
              width: 50,
              child: components.icons.assetAvatar(holding.security.symbol)),
          title: Text(holding.security.symbol,
              style: holding.security.symbol == 'RVN'
                  ? Theme.of(context).textTheme.bodyText1
                  : Theme.of(context).textTheme.bodyText2),
          trailing: Text(
              components.text.securityAsReadable(holding.value,
                  security: holding.security, asUSD: showUSD),
              style: TextStyle(color: Theme.of(context).good)));
      if (holding.security.symbol == 'RVN') {
        rvnHolding.add(thisHolding);

        /// create asset should allow you to create an asset using a speicific address...
        // hide create asset button - not beta
        //if (holding.value < 600) {
        //  rvnHolding.add(ListTile(
        //      onTap: () {},
        //      title: Text('+ Create Asset (not enough RVN)',
        //          style: TextStyle(color: Theme.of(context).disabledColor))));
        //} else {
        //  rvnHolding.add(ListTile(
        //      onTap: () {},
        //      title: TextButton.icon(
        //          onPressed: () => Navigator.pushNamed(context, '/create',
        //            arguments: {'walletId': wallet?.walletId ?? null}),
        //          icon: Icon(Icons.add),
        //          label: Text('Create Asset'))));
        //}
      } else {
        assetHoldings.add(thisHolding);
      }
    }
    if (rvnHolding.isEmpty) {
      rvnHolding.add(ListTile(
          onTap: () {},
          onLongPress: onLongPress != null ? onLongPress() : () {},
          title: Text('RVN', style: Theme.of(context).textTheme.bodyText1),
          trailing: Text(showUSD ? '\$ 0' : '0',
              style: TextStyle(color: Theme.of(context).fine)),
          leading: Container(
              height: 50,
              width: 50,
              child: components.icons.assetAvatar('RVN'))));
      //rvnHolding.add(ListTile(
      //    onTap: () {},
      //    title: Text('+ Create Asset (not enough RVN)',
      //        style: TextStyle(color: Theme.of(context).disabledColor))));
    }

    return ListView(children: <Widget>[...rvnHolding, ...assetHoldings]);
  }

  static Container _emptyMessage(
    BuildContext context, {
    required String msg,
    IconData? icon,
  }) =>
      Container(
          alignment: Alignment.center,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon ?? Icons.savings,
                size: 50.0, color: Theme.of(context).secondaryHeaderColor),
            Text(msg, style: Theme.of(context).textTheme.bodyText1),
            //RavenButton.getRVN(context), // hidden for alpha
          ]));
}
