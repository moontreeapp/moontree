import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intersperse/intersperse.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/app.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/theme/theme.dart';
import 'package:raven_front/widgets/bottom/selection_items.dart';
import 'package:raven_back/streams/client.dart';

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
  ConnectionStatus connectionStatus = ConnectionStatus.disconnected;

  @override
  void initState() {
    super.initState();
    listeners.add(streams.app.wallet.isEmpty.listen((bool value) {
      if (walletIsEmpty != value) {
        setState(() {
          walletIsEmpty = value;
        });
      }
    }));
    listeners.add(streams.client.connected.listen((ConnectionStatus value) {
      if (connectionStatus != value) {
        setState(() {
          connectionStatus = value;
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
              walletIsEmpty
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
                      enabled: connectionStatus == ConnectionStatus.connected,
                      disabledOnPressed: () {
                        print('disabled');
                        streams.app.snack.add(Snack(
                          message: 'Not connected to Network',
                        ));
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
