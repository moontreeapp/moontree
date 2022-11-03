import 'dart:async';
import 'dart:math';
import 'package:collection/collection.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_back/streams/spend.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/services/lookup.dart';
import 'package:ravencoin_front/theme/colors.dart';
import 'package:ravencoin_front/widgets/widgets.dart';
import 'package:shimmer/shimmer.dart';

final rvn = pros.securities.RVN.symbol;
final evr = pros.securities.EVR.symbol;

class HoldingList extends StatefulWidget {
  final Iterable<Balance>? holdings;
  final ScrollController? scrollController;

  const HoldingList({
    this.scrollController,
    this.holdings,
    Key? key,
  }) : super(key: key);

  @override
  State<HoldingList> createState() => _HoldingList();
}

class _HoldingList extends State<HoldingList> {
  List<StreamSubscription> listeners = [];
  List<AssetHolding>? holdings = null;
  int holdingCount = 0;
  bool showUSD = false;
  bool showPath = false;
  bool overrideEmpty = false;
  bool showSearchBar = false;
  Rate? rateUSD;
  Set<Balance> balances = {};
  Set<Address> addresses = {};
  TextEditingController searchController = TextEditingController();
  bool overrideGettingStarted = false;

  int getCount() {
    var x = Current.wallet.holdingCount;
    if (x == 0) {
      x = pros.assets.length;
    }
    return (Current.wallet.RVNValue > 0 ? 1 : 0) + x;
  }

  @override
  void initState() {
    super.initState();
    holdingCount = getCount();
    if (services.download.overrideGettingStarted) {
      /// keep it until entire app reload
      //services.download.overrideGettingStarted = false;
      overrideGettingStarted = true;
    }
    listeners
        .add(pros.assets.batchedChanges.listen((List<Change<Asset>> changes) {
      // need a way to know this wallet's asset list without vouts for newLeaderProcess
      var count = getCount();
      if (count > holdingCount) {
        holdingCount = count;
      }
    }));

    /// when the app becomes active again refresh the front end
    listeners.add(streams.app.active.listen((bool active) async {
      if (active) {
        print('triggered by activity');
        setState(() {});
      }
    }));
  }

  @override
  void dispose() {
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  // ignore: unused_element
  void _toggleUSD() {
    setState(() {
      if (pros.rates.primaryIndex
              .getOne(pros.securities.RVN, pros.securities.USD) ==
          null) {
        showUSD = false;
      } else {
        showUSD = !showUSD;
      }
    });
  }

  void _togglePath() {
    setState(() => showPath = !showPath);
  }

  Future refresh() async {
    print('sup');
    await services.balance.recalculateAllBalances();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    balances = Current.wallet.balances.toSet();
    addresses = Current.wallet.addresses.toSet();
    final transactions = Current.wallet.transactions.toSet();
    holdings = (
        //holdings != null && holdings!.isNotEmpty
        //    ? holdings
        //    :
        utils.assetHoldings(widget.holdings ??
            //services.download.unspents
            //    .unspentBalancesByWalletId[Current.walletId] ??
            //[]
            balances));

    /// affects https://github.com/moontreeapp/moontreeV1/issues/648
    // filter out empties unless all we have is one item (empty RVN)
    if (holdings != null && holdings!.length > 1) {
      holdings = holdings!.where((holding) => holding.value > 0).toList();
    }

    bool overrideEmptyEcho = false;
    if (overrideEmpty) {
      overrideEmpty = false;
      overrideEmptyEcho = true;
      final walletId = Current.walletId;
      balances = {};
      for (final symbol in pros.wallets.primaryIndex
          .getOne(walletId)!
          .addresses
          .map((a) => a.vouts)
          .expand((i) => i)
          .map((v) => v.assetSecurityId?.split(':').first ?? 'RVN')
          .toSet()) {
        balances.add(Balance(
            walletId: walletId,
            security: pros.securities.bySymbol.getAll(symbol).firstOrNull ??
                Security(
                  symbol: symbol,
                  securityType: SecurityType.asset,
                  chain: pros.settings.chain,
                  net: pros.settings.net,
                ),
            confirmed: 0,
            unconfirmed: 0));
      }
      holdings = utils.assetHoldings(balances);
    }
    if (overrideEmptyEcho) {
      return _holdingsView(context, isEmpty: true);
    }

    /*
    Only have 1 wallet, no balances, no transactions - Getting Started Screen
    no balances, no transactions, busy - shimmering.
    no balances, no transactions, not busy - this wallet is empty, here's the address
    no balances, transactions - zero balances?
    balances, no transactions - show balances
    balances, transactions - show balances
    */
    final currentIsLeader = Current.wallet is LeaderWallet;
    final busy = currentIsLeader
        ? streams.client.busy.value || addresses.length < 40
        : false;
    if (!currentIsLeader) {
      // single wallets sometimes never stop spinning
      streams.client.busy.add(false);
    }

    if (overrideGettingStarted && balances.isEmpty) {
      return components.empty.getAssetsPlaceholder(context,
          scrollController: widget.scrollController,
          count: max(holdingCount, 1),
          holding: true);
    }
    if (overrideGettingStarted) {
      return _holdingsView(context);
    }

    if (pros.wallets.length == 1 && balances.isEmpty && transactions.isEmpty) {
      return ComingSoonPlaceholder(
          scrollController: widget.scrollController,
          header: 'Get Started',
          message:
              'Use the Import or Receive button to add Ravencoin & assets to your wallet.',
          placeholderType: PlaceholderType.wallet);
    } else if (balances.isEmpty && transactions.isEmpty && busy) {
      return components.empty.getAssetsPlaceholder(context,
          scrollController: widget.scrollController,
          count: max(holdingCount, 1),
          holding: true);
    } else if (balances.isEmpty && transactions.isEmpty && !busy) {
      return ComingSoonPlaceholder(
          scrollController: widget.scrollController,
          header: 'Empty Wallet',
          message:
              'This wallet has never been used before.\nClick "Receive" to get started.',
          placeholderType: PlaceholderType.wallet);
    } else if (balances.isEmpty && transactions.isNotEmpty && !busy) {
      ///// if they have removed all assets and rvn from wallet, for each asset
      ///// we've ever held, create empty Balance, and empty AssetHolding.
      //if (!services.wallet.leader.newLeaderProcessRunning &&
      //    addresses.isNotEmpty &&
      //    balances.isEmpty &&
      //    transactions.isNotEmpty) {
      //  ///https://github.com/moontreeapp/moontreeV1/issues/648
      //  //for (var security in utils.securityFromTransactions(transactions)) {
      //  //  balances.add(Balance(
      //  //      walletId: Current.walletId,
      //  //      security: security,
      //  //      confirmed: 0,
      //  //      unconfirmed: 0));
      //  //}
      //  ///actually just show rvn.
      //  balances.add(Balance(
      //      walletId: Current.walletId,
      //      security: pros.securities.RVN,
      //      confirmed: 0,
      //      unconfirmed: 0));
      //} my8ZWfDD8LitTMTQj3Pd7NofVh764HfYoZ
      return ComingSoonPlaceholder(
          scrollController: widget.scrollController,
          header: 'Empty Wallet',
          message: 'This wallet appears empty but has a transaction history.',
          placeholderType: PlaceholderType.wallet,
          behavior: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              components.buttons.actionButtonSoft(
                context,
                label: 'Show Empty Balances',
                onPressed: () async {
                  setState(() => overrideEmpty = true);
                },
              )
            ],
          ));
    } else if (balances.isEmpty && transactions.isNotEmpty && busy) {
      return _holdingsView(context);
    } else if (balances.isNotEmpty) {
      return _holdingsView(context);
      //return RefreshIndicator(
      //  child:
      //  onRefresh: () => refresh(),
      //);
    } else {
      return _holdingsView(context);
    }
  }

  void navigate(Balance balance, {Wallet? wallet}) {
    streams.app.wallet.asset.add(balance.security.symbol);
    streams.spend.form.add(SpendForm.merge(
        form: streams.spend.form.value, symbol: balance.security.symbol));
    Navigator.of(components.navigator.routeContext!).pushNamed(
      '/transactions',
      arguments: {'holding': balance, 'walletId': wallet?.id ?? null},
    );
  }

  Widget _holdingsView(
    BuildContext context, {
    Wallet? wallet,
    bool isEmpty = false,
  }) {
    var rvnHolding = <Widget>[];
    var assetHoldings = <Widget>[];
    final searchBar = Padding(
        padding: EdgeInsets.only(top: 1, bottom: 16, left: 16, right: 16),
        child: TextFieldFormatted(
            controller: searchController,
            //focusedErrorBorder: InputBorder.none,
            //errorBorder: InputBorder.none,
            //focusedBorder: InputBorder.none,
            //enabledBorder: InputBorder.none,
            //disabledBorder: InputBorder.none,
            contentPadding: EdgeInsets.only(left: 16, top: 16, bottom: 16),
            autocorrect: false,
            textInputAction: TextInputAction.done,
            labelText: 'Search',
            suffixIcon: IconButton(
              icon: Padding(
                  padding: EdgeInsets.only(top: 0, right: 14),
                  child: Icon(Icons.clear_rounded, color: AppColors.black38)),
              onPressed: () => setState(() {
                searchController.text = '';
                showSearchBar = false;
              }),
            ),
            onChanged: (_) => setState(() {}),
            onEditingComplete: () => setState(() => showSearchBar = false)));
    for (AssetHolding holding in holdings ?? []) {
      if (holding.symbol.startsWith('RVN')) {
        print(holding);
      }
      var thisHolding = ListTile(
          //dense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          onTap: () => onTap(wallet, holding),
          onLongPress: _togglePath,
          leading: leadingIcon(holding),
          title: title(holding),
          trailing: pros.settings.developerMode == true
              ? ((holding.symbol == rvn || holding.symbol == evr) && !isEmpty
                  ? GestureDetector(
                      onTap: () =>
                          setState(() => showSearchBar = !showSearchBar),
                      child: searchController.text == ''
                          ? Icon(Icons.search)
                          : Icon(
                              Icons.search,
                              shadows: [
                                Shadow(
                                    color: AppColors.black12,
                                    offset: Offset(1, 1),
                                    blurRadius: 1),
                                Shadow(
                                    color: AppColors.black12,
                                    offset: Offset(1, 2),
                                    blurRadius: 2)
                              ],
                            ))
                  : null)
              : null);
      if (holding.symbol == rvn || holding.symbol == evr) {
        rvnHolding.add(Container(
            //duration: Duration(milliseconds: 500),
            child: Column(
          children: [
            thisHolding,
            if (showSearchBar && !isEmpty) searchBar,
          ],
        )));
        rvnHolding.add(Divider(
          height: 1,
          indent: 70,
          endIndent: 0,
        ));
      } else {
        if (searchController.text == '' ||
            holding.symbol.contains(searchController.text.toUpperCase())) {
          assetHoldings.add(thisHolding);
          assetHoldings.add(Divider(height: 1));
        }
      }
    }

    /// this case is when we haven't started downloading anything yet.
    if (rvnHolding.isEmpty && assetHoldings.isEmpty) {
      rvnHolding.add(Shimmer.fromColors(
          baseColor: AppColors.primaries[0],
          highlightColor: Colors.white,
          child: components.empty.holdingPlaceholder(context)));
    }

    /// in this case we're looking at an wallet in the EVR blockchain
    final claimInvite = <Widget>[];
    if ( //pros.settings.advancedDeveloperMode == true ||
        (pros.settings.chain == Chain.evrmore &&
            pros.blocks.records.first.height <= 60 * 24 * 60 &&
            pros.unspents.records.where((u) => u.height == 0).length > 0)) {
      claimInvite.add(ListTile(
          //dense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          onTap: () async => await components.message.giveChoices(
                context,
                title: 'Claim Your EVR',
                content: ('All EVR in the Evrmore fairdrop must be claimed '
                    'within 60 days of the snapshot (which occured on october '
                    '25th 2022). Claim your EVR now!'),
                behaviors: {
                  'OK': () => Navigator.of(context).pop(),
                },
              ),
          //onLongPress: popup^,
          leading: Container(
              height: 40,
              width: 40,
              child: components.icons.assetAvatar('EVR')),
          title: Text('Evrmore', style: Theme.of(context).textTheme.bodyText1),
          trailing: ClaimEvr()));
      claimInvite.add(Divider(height: 1));
    }

    final listView = ListView(
        controller: widget.scrollController,
        dragStartBehavior: DragStartBehavior.start,
        physics: ClampingScrollPhysics(),
        children: claimInvite.length > 0
            ? claimInvite
            : <Widget>[
                ...rvnHolding,
                ...assetHoldings,
                ...[components.empty.blankNavArea(context)]
              ]);
    //if (pros.settings.advancedDeveloperMode == true) {
    //  return RefreshIndicator(
    //    onRefresh: () async {
    //      streams.app.snack.add(Snack(message: 'Resyncing...'));
    //      await services.client.resetMemoryAndConnection();
    //      setState(() {});
    //    },
    //    child: listView,
    //  );
    //}
    return GestureDetector(
      onTap: () async => setState(() {
        print('refresh1');
        FocusScope.of(context).unfocus;
      }),
      child: listView,
    );
  }

  void onTap(Wallet? wallet, AssetHolding holding) {
    if (overrideGettingStarted) {
      //components.message.giveChoices(context,
      //    title: 'Still Syncing',
      //    content: 'please try again later.',
      //    behaviors: {'ok': () => Navigator.of(context).pop()});
    }
    if (holding.length == 1) {
      navigate(holding.balance!, wallet: wallet);
    } else {
      SelectionItems(
        context,
        symbol: holding.symbol,
        names: [
          if (holding.main != null) SelectionOption.Main,
          if (holding.sub != null) SelectionOption.Sub,
          if (holding.subAdmin != null) SelectionOption.Sub_Admin,
          if (holding.admin != null) SelectionOption.Admin,
          if (holding.restricted != null) SelectionOption.Restricted,
          if (holding.restrictedAdmin != null) SelectionOption.Restricted_Admin,
          if (holding.qualifier != null) SelectionOption.Qualifier,
          if (holding.qualifierSub != null) SelectionOption.Sub_Qualifier,
          if (holding.nft != null) SelectionOption.NFT,
          if (holding.channel != null) SelectionOption.Channel,
        ],
        behaviors: [
          if (holding.main != null)
            () => navigate(holding.main!, wallet: wallet),
          if (holding.sub != null)
            () => navigate(holding.sub!, wallet: wallet), /////
          if (holding.subAdmin != null)
            () => navigate(holding.subAdmin!, wallet: wallet),
          if (holding.admin != null)
            () => navigate(holding.admin!, wallet: wallet),
          if (holding.restricted != null)
            () => navigate(holding.restricted!, wallet: wallet),
          if (holding.restrictedAdmin != null)
            () => navigate(holding.restrictedAdmin!, wallet: wallet),
          if (holding.qualifier != null)
            () => navigate(holding.qualifier!, wallet: wallet),
          if (holding.qualifierSub != null)
            () => navigate(holding.qualifierSub!, wallet: wallet),
          if (holding.nft != null)
            () => navigate(holding.nft!, wallet: wallet), /////
          if (holding.channel != null)
            () => navigate(holding.channel!, wallet: wallet),
        ],
        values: [
          if (holding.main != null)
            components.text.securityAsReadable(
              holding.main!.value,
              security: holding.main!.security,
              asUSD: showUSD,
            ),
          if (holding.sub != null)
            components.text.securityAsReadable(
              holding.sub!.value,
              security: holding.sub!.security,
              asUSD: showUSD,
            ),
          if (holding.subAdmin != null)
            components.text.securityAsReadable(
              holding.subAdmin!.value,
              security: holding.subAdmin!.security,
              asUSD: showUSD,
            ),
          if (holding.admin != null)
            components.text.securityAsReadable(
              holding.admin!.value,
              security: holding.admin!.security,
              asUSD: showUSD,
            ),
          if (holding.restricted != null)
            components.text.securityAsReadable(
              holding.restricted!.value,
              security: holding.restricted!.security,
              asUSD: showUSD,
            ),
          if (holding.restrictedAdmin != null)
            components.text.securityAsReadable(
              holding.restrictedAdmin!.value,
              security: holding.restrictedAdmin!.security,
              asUSD: showUSD,
            ),
          if (holding.qualifier != null)
            components.text.securityAsReadable(
              holding.qualifier!.value,
              security: holding.qualifier!.security,
              asUSD: showUSD,
            ),
          if (holding.qualifierSub != null)
            components.text.securityAsReadable(
              holding.qualifierSub!.value,
              security: holding.qualifierSub!.security,
              asUSD: showUSD,
            ),
          if (holding.nft != null)
            components.text.securityAsReadable(
              holding.nft!.value,
              security: holding.nft!.security,
              asUSD: showUSD,
            ),
          if (holding.channel != null)
            components.text.securityAsReadable(
              holding.channel!.value,
              security: holding.channel!.security,
              asUSD: showUSD,
            ),
        ],
      ).build();
    }
  }

  Widget leadingIcon(AssetHolding holding) => Container(
          height: 40,
          width: 40,
          child: //Hero(
              //tag: holding.symbol.toLowerCase(),
              //child:
              components.icons.assetAvatar(
                  holding.admin != null
                      ? holding.adminSymbol!
                      : holding.restricted != null
                          ? holding.restrictedSymbol!
                          : holding.qualifier != null
                              ? holding.qualifierSymbol!
                              : holding.channel != null
                                  ? holding.channelSymbol!
                                  : holding.nft != null
                                      ? holding.nftSymbol!
                                      : holding.subAdmin != null
                                          ? holding.subAdminSymbol!
                                          : holding.sub != null
                                              ? holding.subSymbol!
                                              : holding.qualifierSub != null
                                                  ? holding.qualifierSubSymbol!
                                                  : holding.symbol,
                  net: pros.settings.net))
      //)
      ;

  Widget title(AssetHolding holding) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Container(
              width: holding.symbol == rvn || holding.symbol == evr
                  ? MediaQuery.of(context).size.width / 2
                  : MediaQuery.of(context).size.width - (16 + 40 + 16 + 16),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                    holding.symbol == rvn || holding.symbol == evr
                        ? symbolName(holding.symbol)
                        : pros.settings.developerMode && showPath
                            ? holding.symbol
                            : holding.last,
                    style: Theme.of(context).textTheme.bodyText1),
              )),
        ]),
        Text(
          holding.mainLength > 1 && holding.restricted != null
              ? [
                  if (holding.main != null) 'Main',
                  if (holding.admin != null) 'Admin',
                  if (holding.restricted != null) 'Restricted',
                  if (holding.restrictedAdmin != null) 'Restricted Admin',
                ].join(', ')
              : components.text.securityAsReadable(holding.balance?.value ?? 0,
                  security: holding.balance?.security ??
                      Security(
                        symbol: 'unknown',
                        securityType: SecurityType.fiat,
                        chain: Chain.none,
                        net: Net.test,
                      ),
                  asUSD: showUSD),
          style: Theme.of(context)
              .textTheme
              .bodyText2!
              .copyWith(color: AppColors.black60),
        ),
      ]);
}
