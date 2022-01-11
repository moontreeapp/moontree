import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/services/identicon.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/theme/extensions.dart';

class HoldingList extends StatefulWidget {
  final Iterable<Balance>? holdings;
  const HoldingList({this.holdings, Key? key}) : super(key: key);

  @override
  State<HoldingList> createState() => _HoldingList();
}

class _HoldingList extends State<HoldingList> {
  List<StreamSubscription> listeners = [];
  late Iterable<Balance> holdings;
  bool showUSD = false;
  Rate? rateUSD;

  @override
  void initState() {
    super.initState();
    listeners
        .add(vouts.batchedChanges.listen((List<Change<Vout>> batchedChanges) {
      // if vouts in our account has changed...
      if (batchedChanges
          .where((change) =>
              change.data.address?.wallet?.accountId == Current.accountId)
          .isNotEmpty) {
        setState(() {});
      }
    }));
    listeners.add(rates.batchedChanges.listen((batchedChanges) {
      // ignore: todo
      // TODO: should probably include any assets that are in the holding of the main account too...
      var changes = batchedChanges.where((change) =>
          change.data.base == securities.RVN &&
          change.data.quote == securities.USD);
      if (changes.isNotEmpty)
        setState(() {
          rateUSD = changes.first.data;
        });
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
      if (rates.primaryIndex.getOne(securities.RVN, securities.USD) == null) {
        showUSD = false;
      } else {
        showUSD = !showUSD;
      }
    });
  }

  Future refresh() async {
    await services.address.triggerDeriveOrBalance();
    await services.rate.saveRate();
    await services.balance.recalculateAllBalances();
    setState(() {});
    // showing snackbar
    //_scaffoldKey.currentState.showSnackBar(
    //  SnackBar(
    //    content: const Text('Page Refreshed'),
    //  ),
    //);
  }

  @override
  Widget build(BuildContext context) {
    holdings = widget.holdings ?? Current.holdings;
    //services.balance.accountBalances(
    //        accounts.primaryIndex.getOne(widget.currentAccountId!)!)
    //    : services.balance.addressesBalances(
    //        [addresses.byAddress.getOne(widget.currentWalletAddress!)!]);
    return holdings.isEmpty // <-- on front tab...
        //? components.empty.holdings(context)
        ? Container(
            color: Colors.transparent,
            child: ListView(children: [
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
              Text('hi'),
            ]))
        : Container(
            color: Colors.transparent,
            alignment: Alignment.center,
            padding: EdgeInsets.only(top: 5.0),
            child: RefreshIndicator(
              child: _holdingsView(context),
              onRefresh: () => refresh(),
            ));
  }

  ListView _holdingsView(BuildContext context, {Wallet? wallet}) {
    var rvnHolding = <Widget>[];
    var assetHoldings = <Widget>[];
    for (var holding in holdings) {
      var thisHolding = ListTile(
          onTap: () => Navigator.pushNamed(context,
                  holding.security.symbol == 'RVN' ? '/transactions' : '/asset',
                  arguments: {
                    'holding': holding,
                    'walletId': wallet?.walletId ?? null
                  }), // wallet transactions are on wallet screen, so remove wallet id here.
          leading: Container(
              height: 40,
              width: 40,
              child: components.icons.assetAvatar(holding.security.symbol)),
          title: Text(holding.security.symbol,
              style: Theme.of(context).holdingName),
          trailing: Text(
              components.text.securityAsReadable(holding.value,
                  security: holding.security, asUSD: showUSD),
              style: Theme.of(context).holdingValue));
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
        //          onPressed: () => Navigator.pushNamed(context, '/transaction/create',
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
          title: Text('RVN', style: Theme.of(context).holdingName),
          trailing: Text(showUSD ? '\$ 0' : '0',
              style: Theme.of(context).holdingValue),
          leading: Container(
              height: 50,
              width: 50,
              child: components.icons.assetAvatar('RVN'))));
      //rvnHolding.add(ListTile(
      //    onTap: () {},
      //    title: Text('+ Create Asset (not enough RVN)',
      //        style: TextStyle(color: Theme.of(context).disabledColor))));
    }

    return ListView(children: <Widget>[
      SvgPicture.string(
          '<svg xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cc="http://creativecommons.org/ns#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:svg="http://www.w3.org/2000/svg" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 5 5" shape-rendering="crispEdges" width="40" height="40"><metadata><rdf:RDF><cc:Work><dc:format>image/svg+xml</dc:format><dc:type rdf:resource="http://purl.org/dc/dcmitype/StillImage"/><dc:title>Identicon</dc:title><dc:creator><cc:Agent><dc:title>Florian Körner</dc:title></cc:Agent></dc:creator><dc:source>https://github.com/dicebear/dicebear</dc:source><cc:license rdf:resource="https://creativecommons.org/publicdomain/zero/1.0/"/></cc:Work><cc:License rdf:about="https://creativecommons.org/publicdomain/zero/1.0/"><cc:permits rdf:resource="https://creativecommons.org/ns#Reproduction"/><cc:permits rdf:resource="https://creativecommons.org/ns#Distribution"/><cc:permits rdf:resource="https://creativecommons.org/ns#DerivativeWorks"/></cc:License></rdf:RDF></metadata><mask id="avatarsRadiusMask"><rect width="5" height="5" rx="2.5" ry="2.5" x="0" y="0" fill="#fff"/></mask><g mask="url(#avatarsRadiusMask)"><rect fill="#F57D00" width="5" height="5" x="0" y="0"/><path d="M0 4h1v1H0V4zm4 0h1v1H4V4z" fill-rule="evenodd" fill="#FDD835"/><path d="M1 3h3v1H1V3z" fill="#FDD835"/><path d="M0 2h1v1H0V2zm4 0h1v1H4V2z" fill-rule="evenodd" fill="#FDD835"/><path d="M1 1h3v1H1V1z" fill="#FDD835"/><path d="M0 0h5v1H0V0z" fill="#FDD835"/></g></svg>',
          width: 40,
          height: 40),
      SvgPicture.network(
          Identicon(
            name: 'random_file_name.svg',
            size: 40,
            radius: 50,
            background: '23F57D00',
          ).url,
          width: 40,
          height: 40),
      ...rvnHolding,
      ...assetHoldings
    ]);
  }
}
