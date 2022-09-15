import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intersperse/intersperse.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/services/lookup.dart';
import 'package:ravencoin_front/theme/theme.dart';
import 'package:ravencoin_front/widgets/bottom/selection_items.dart';
import 'package:ravencoin_back/streams/client.dart';

class NavBar extends StatefulWidget {
  final AppContext? appContext;
  final Iterable<Widget>? actionButtons;
  final bool includeSectors;
  final bool placeholderManage;
  final bool placeholderSwap;

  NavBar({
    Key? key,
    this.appContext,
    this.actionButtons,
    this.includeSectors = true,
    this.placeholderManage = false,
    this.placeholderSwap = false,
  }) : super(key: key) {
    if (appContext == null && actionButtons == null) {
      throw OneOfMultipleMissing(
          'NavBar needs appContext or actionButtons supplied.');
    }
  }

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  List<StreamSubscription> listeners = [];
  bool walletIsEmpty = false;
  bool walletHasTransactions = false;
  ConnectionStatus connectionStatus = ConnectionStatus.disconnected;
  late Set<Balance> balances = {};

  @override
  void initState() {
    super.initState();
    listeners.add(streams.client.connected.listen((ConnectionStatus value) {
      if (connectionStatus != value) {
        setState(() {
          connectionStatus = value;
        });
      }
    }));
    listeners.add(pros.balances.batchedChanges
        .listen((List<Change<Balance>> changes) async {
      var interimBalances = Current.wallet.balances.toSet();
      if (balances != interimBalances) {
        setState(() {
          balances = interimBalances;
        });
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

  @override
  Widget build(BuildContext context) {
    walletHasTransactions = Current.wallet.transactions.isNotEmpty;
    walletIsEmpty = Current.wallet.balances.isEmpty;
    streams.app.navHeight
        .add(widget.includeSectors ? NavHeight.tall : NavHeight.short);
    return components.containers.navBar(context,
        tall: widget.includeSectors,
        child: SingleChildScrollView(
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // we will need to make these buttons dependant upon the navigation
              // of the front page through streams but for now, we'll show they
              // can changed based upon whats selected:
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:
                    actionButtons.intersperse(SizedBox(width: 16)).toList(),
              ),
              if (widget.includeSectors) ...[
                SizedBox(height: 6),
                Padding(
                    padding: EdgeInsets.only(left: 0, right: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        sectorIcon(appContext: AppContext.wallet),
                        sectorIcon(appContext: AppContext.manage),
                        sectorIcon(appContext: AppContext.swap),
                      ],
                    ))
              ]
            ],
          ),
        ));
  }

  Iterable<Widget> get actionButtons =>
      widget.actionButtons ??
      (widget.appContext == AppContext.wallet
          ? <Widget>[
              walletIsEmpty &&
                      !walletHasTransactions &&
                      streams.import.result.value ==
                          null // transactions take a while to show up, so after import make sure to change the button.
                  ? components.buttons.actionButton(
                      context,
                      label: 'import',
                      onPressed: () async {
                        Navigator.of(components.navigator.routeContext!)
                            .pushNamed('/settings/import');
                      },
                    )
                  : components.buttons.actionButton(
                      context,
                      label: 'send',
                      enabled: !walletIsEmpty &&
                          connectionStatus == ConnectionStatus.connected,
                      disabledOnPressed: () {
                        if (connectionStatus != ConnectionStatus.connected) {
                          streams.app.snack
                              .add(Snack(message: 'Not connected to network'));
                        } else {
                          // walletIsEmpty
                          streams.app.snack.add(Snack(
                              message:
                                  'This wallet has no Ravencoin, unable to send.'));
                        }
                      },
                      onPressed: () async {
                        Navigator.of(components.navigator.routeContext!)
                            .pushNamed('/transaction/send');
                        if (Current.wallet is LeaderWallet &&
                            streams.app.triggers.value ==
                                ThresholdTrigger.backup &&
                            !Current.wallet.backedUp) {
                          await Future.delayed(Duration(milliseconds: 800));
                          streams.app.xlead.add(true);
                          Navigator.of(components.navigator.routeContext!)
                              .pushNamed(
                            '/security/backup',
                            arguments: {'fadeIn': true},
                          );
                        }
                      },
                    ),
              components.buttons.actionButton(
                context,
                label: 'receive',
                onPressed: () async {
                  Navigator.of(components.navigator.routeContext!)
                      .pushNamed('/transaction/receive');
                  if (Current.wallet is LeaderWallet &&
                      streams.app.triggers.value == ThresholdTrigger.backup &&
                      !Current.wallet.backedUp) {
                    await Future.delayed(Duration(milliseconds: 800));
                    streams.app.xlead.add(true);
                    Navigator.of(components.navigator.routeContext!).pushNamed(
                      '/security/backup',
                      arguments: {'fadeIn': true},
                    );
                  }
                },
              )
            ]
          : widget.appContext == AppContext.manage
              ? <Widget>[
                  components.buttons.actionButton(
                    context,
                    label: 'create',
                    enabled: !widget.placeholderManage,
                    onPressed: () {
                      _produceCreateModal(context);
                    },
                  )
                ]
              : <Widget>[
                  components.buttons.actionButton(
                    context,
                    label: 'buy',
                    enabled: !widget.placeholderSwap,
                    onPressed: () {
                      _produceCreateModal(context);
                    },
                  ),
                  components.buttons.actionButton(
                    context,
                    label: 'sell',
                    enabled: !widget.placeholderSwap,
                    onPressed: () {
                      _produceCreateModal(context);
                    },
                  )
                ]);

  Widget sectorIcon({required AppContext appContext}) => Container(
      height: 56,
      width: (MediaQuery.of(context).size.width - 32 - 0) / 3,
      alignment: Alignment.center,
      child: IconButton(
        onPressed: () {
          streams.app.context.add(appContext);
          if (!['Home', 'Manage', 'Swap'].contains(streams.app.page.value)) {
            Navigator.popUntil(components.navigator.routeContext!,
                ModalRoute.withName('/home'));
          }
        },
        icon: Icon({
          AppContext.wallet: MdiIcons.wallet,
          AppContext.manage: MdiIcons.plusCircle,
          AppContext.swap: MdiIcons.swapHorizontalBold,
        }[appContext]!),
        iconSize: streams.app.context.value == appContext ? 32 : 24,
        color: streams.app.context.value == appContext
            ? AppColors.primary
            : Color(0x995C6BC0),
      ));

  void _produceCreateModal(BuildContext context) {
    SelectionItems(context, modalSet: SelectionSet.Create).build();
  }
}
