import 'dart:async';
import 'package:intersperse/intersperse.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_back/streams/client.dart';
import 'package:client_front/presentation/components/components.dart';
import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:client_front/presentation/theme/theme.dart';
import 'package:client_front/presentation/widgets/bottom/selection_items.dart';

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
  List<StreamSubscription<dynamic>> listeners = <StreamSubscription<dynamic>>[];
  bool walletIsEmpty = false;
  bool walletHasTransactions = false;
  ConnectionStatus connectionStatus = ConnectionStatus.disconnected;
  late Set<Balance> balances = <Balance>{};

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
      final Set<Balance> interimBalances = Current.wallet.balances.toSet();
      if (balances != interimBalances) {
        setState(() {
          balances = interimBalances;
        });
      }
    }));
  }

  @override
  void dispose() {
    for (final StreamSubscription<dynamic> listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    walletHasTransactions = Current.wallet.transactions.isNotEmpty;
    walletIsEmpty = Current.wallet.balances.isEmpty;
    streams.app.navHeight.add(
        false /*widget.includeSectors*/ ? NavHeight.tall : NavHeight.short);
    return components.containers.navBar(context /*widget.includeSectors*/,
        child: SingleChildScrollView(
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // we will need to make these buttons dependant upon the navigation
              // of the front page through streams but for now, we'll show they
              // can changed based upon whats selected:
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: actionButtons
                    .intersperse(const SizedBox(width: 16))
                    .toList(),
              ),
              if (false /*widget.includeSectors*/) ...<Widget>[
                const SizedBox(height: 6),
                Padding(
                    padding: EdgeInsets.zero,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
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
              if (walletIsEmpty &&
                  !walletHasTransactions &&
                  streams.import.result.value == null)
                components.buttons.actionButton(
                  context,
                  label: 'import',
                  onPressed: () async {
                    Navigator.of(components.routes.routeContext!)
                        .pushNamed('/settings/import');
                  },
                )
              else
                components.buttons.actionButton(
                  context,
                  label: 'send',
                  enabled:
                      //!(pros.settings.chain == Chain.evrmore &&
                      //        pros.blocks.records.first.height <=
                      //            60 * 24 * 60 &&
                      //        pros.unspents.records
                      //                .where((u) => u.height == 0)
                      //                .length >
                      //            0)
                      !walletIsEmpty &&
                          connectionStatus == ConnectionStatus.connected,
                  disabledOnPressed: () {
                    if (connectionStatus != ConnectionStatus.connected) {
                      streams.app.snack
                          .add(Snack(message: 'Not connected to network'));
                    } else if (walletIsEmpty) {
                      streams.app.snack.add(Snack(
                          message: 'This wallet has no coin, unable to send.'));
                    } else {
                      streams.app.snack
                          .add(Snack(message: 'Claimed your EVR first.'));
                    }
                  },
                  onPressed: () => Navigator.of(components.routes.routeContext!)
                      .pushNamed('/transaction/send'),
                ),
              components.buttons.actionButton(
                context,
                label: 'receive',
                onPressed: () => Navigator.of(components.routes.routeContext!)
                    .pushNamed('/transaction/receive'),
              )
            ]
          : widget.appContext == AppContext.manage
              ? <Widget>[
                  components.buttons.actionButton(
                    context,
                    label: 'create',
                    enabled: !widget.placeholderManage,
                    onPressed: () => _produceCreateModal(context),
                  )
                ]
              : <Widget>[
                  components.buttons.actionButton(
                    context,
                    label: 'buy',
                    enabled: !widget.placeholderSwap,
                    onPressed: () => _produceCreateModal(context),
                  ),
                  components.buttons.actionButton(
                    context,
                    label: 'sell',
                    enabled: !widget.placeholderSwap,
                    onPressed: () => _produceCreateModal(context),
                  )
                ]);

  Widget sectorIcon({required AppContext appContext}) => Container(
      height: 56,
      width: (MediaQuery.of(context).size.width - 32 - 0) / 3,
      alignment: Alignment.center,
      child: IconButton(
        onPressed: () {
          streams.app.context.add(appContext);
          if (!<String>['Home', 'Manage', 'Swap']
              .contains(streams.app.page.value)) {
            Navigator.popUntil(
                components.routes.routeContext!, ModalRoute.withName('/home'));
          }
        },
        icon: Icon(<AppContext, IconData>{
          AppContext.wallet: MdiIcons.wallet,
          AppContext.manage: MdiIcons.plusCircle,
          AppContext.swap: MdiIcons.swapHorizontalBold,
        }[appContext]),
        iconSize: streams.app.context.value == appContext ? 32 : 24,
        color: streams.app.context.value == appContext
            ? AppColors.primary
            : const Color(0x995C6BC0),
      ));

  void _produceCreateModal(BuildContext context) {
    SelectionItems(context, modalSet: SelectionSet.Create).build();
  }
}
