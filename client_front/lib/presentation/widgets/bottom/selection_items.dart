/// In order to extend the scrim to the entire page, including the app bar...
/// this should probably be a permanent fixture on the main scaffold,
/// which changes based upon a page or messages from a stream... idk, but,
/// for now we'll put it here because it'll be easy to move to main if we want.
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_front/presentation/components/shapes.dart' as shapes;
import 'package:client_front/presentation/components/components.dart'
    as components;
import 'package:client_back/streams/create.dart';
import 'package:client_back/streams/reissue.dart';
import 'package:client_front/presentation/theme/theme.dart';
import 'package:client_front/domain/utils/extensions.dart';
import 'package:client_front/presentation/widgets/backdrop/backdrop.dart';

import 'package:client_front/domain/utils/alphacon.dart';

enum SelectionSet {
  Fee,
  Decimal,
  Admins,
  Parents,
  Create,
  Manage,
  Asset,
  Sub_Asset,
  Sub_Qualifier,
  Feedback,
  Wallets,
  MainManage
}

enum SelectionOption {
  // list of my assets
  Admins,

  // for admins
  Restricted_Symbol,

  // what to access or create
  Main_Asset,
  Restricted_Asset,
  Qualifier_Asset,
  Admin_Asset,
  NFT_Asset,
  Main,
  Restricted,
  Qualifier,
  Admin,
  Sub_Asset,
  NFT,
  Messaging_Channel_Asset,

  // Main,
  Sub,
  Sub_Admin,
  // NFT,
  // Channel,
  // Admin,
  // Restricted,
  Restricted_Admin,
  // Qualifier,
  Sub_Qualifier,
  QualifierSub,
  Channel,

  // decimals divisibility
  Dec8,
  Dec7,
  Dec6,
  Dec5,
  Dec4,
  Dec3,
  Dec2,
  Dec1,
  Dec0,

  //feedback
  Change,
  Bug,

  // manage
  Reissue,
  Issue_Dividend,

  // Test Widgets
  CustomName,
}

class SelectionItems {
  SelectionItems(
    this.context, {
    List<SelectionOption>? names,
    List<String>? customNames,
    List<VoidCallback>? behaviors,
    List<String>? values,
    this.symbol,
    this.modalSet,
  }) {
    // handle the error here if we have to error.
    this.names = (names ??
            {
              SelectionSet.Admins: <SelectionOption>[SelectionOption.Admins],
              SelectionSet.Decimal: <SelectionOption>[
                SelectionOption.Dec8,
                SelectionOption.Dec7,
                SelectionOption.Dec6,
                SelectionOption.Dec5,
                SelectionOption.Dec4,
                SelectionOption.Dec3,
                SelectionOption.Dec2,
                SelectionOption.Dec1,
                SelectionOption.Dec0,
              ],
              SelectionSet.Create: <SelectionOption>[
                SelectionOption.Main,
                SelectionOption.Sub,
                SelectionOption.Restricted,
                SelectionOption.Qualifier,
                SelectionOption.QualifierSub,
                SelectionOption.NFT,
                SelectionOption.Channel,
              ],
              SelectionSet.Sub_Asset: <SelectionOption>[
                SelectionOption.Sub,
                SelectionOption.NFT,
                SelectionOption.Channel,
              ],
              SelectionSet.Sub_Qualifier: <SelectionOption>[
                SelectionOption.QualifierSub,
              ],
              SelectionSet.Feedback: <SelectionOption>[
                SelectionOption.Change,
                SelectionOption.Bug,
              ],
              SelectionSet.MainManage: <SelectionOption>[
                SelectionOption.Reissue,
                SelectionOption.Issue_Dividend,
              ],
            }[modalSet]) ??
        [];
    this.behaviors = behaviors ?? [];
    this.values = values ?? [];
    this.customNames = customNames ?? [];
  }
  late List<SelectionOption> names;
  late List<String> customNames;
  late List<VoidCallback> behaviors;
  late List<String> values;
  late String? symbol;
  String? symbolColors;
  late SelectionSet? modalSet;
  final BuildContext context;

  String asString(SelectionOption name) =>
      name.name.toTitleCase(underscoresAsSpace: true);

  Widget createLeads(SelectionOption name) {
    final ImageDetails imageDetails =
        components.icons.getImageDetailsAlphacon(symbolColors);
    return components.icons.generateIndicator(
            name: symbolColors,
            imageDetails: imageDetails,
            height: 24,
            width: 24,
            assetType: {
                  SelectionOption.Restricted_Symbol: SymbolType.restricted,
                  SelectionOption.Main_Asset: SymbolType.main,
                  SelectionOption.Restricted_Asset: SymbolType.restricted,
                  SelectionOption.Qualifier_Asset: SymbolType.qualifier,
                  SelectionOption.Admin_Asset: SymbolType.admin,
                  SelectionOption.Main: SymbolType.main,
                  SelectionOption.Restricted: SymbolType.restricted,
                  SelectionOption.NFT_Asset: SymbolType.unique,
                  SelectionOption.Qualifier: SymbolType.qualifier,
                  SelectionOption.Sub_Qualifier: SymbolType.qualifierSub,
                  SelectionOption.QualifierSub: SymbolType.qualifierSub,
                  SelectionOption.Admin: SymbolType.admin,
                  SelectionOption.Sub_Asset: SymbolType.sub,
                  SelectionOption.Sub: SymbolType.sub,
                  SelectionOption.NFT: SymbolType.unique,
                  SelectionOption.Messaging_Channel_Asset: SymbolType.channel,
                  SelectionOption.Channel: SymbolType.channel,
                }[name] ??
                SymbolType.main) ??
        components.icons.assetFromCacheOrGenerate(
            asset: symbolColors,
            height: 24,
            width: 24,
            imageDetails: imageDetails,
            assetType: SymbolType.main);
  }

  Widget leads(SelectionOption name, {String? holding}) => Icon(
      (holding != null
              ? components.icons.assetTypeIcon(name: holding)
              : components.icons.assetTypeIcon(
                  assetType: {
                  SelectionOption.Restricted_Symbol: SymbolType.restricted,
                  SelectionOption.Main_Asset: SymbolType.main,
                  SelectionOption.Restricted_Asset: SymbolType.restricted,
                  SelectionOption.Qualifier_Asset: SymbolType.qualifier,
                  SelectionOption.Admin_Asset: SymbolType.admin,
                  SelectionOption.Main: SymbolType.main,
                  SelectionOption.Restricted: SymbolType.restricted,
                  SelectionOption.NFT_Asset: SymbolType.unique,
                  SelectionOption.Qualifier: SymbolType.qualifier,
                  SelectionOption.Admin: SymbolType.admin,
                  SelectionOption.Sub_Asset: SymbolType.sub,
                  SelectionOption.NFT: SymbolType.unique,
                  SelectionOption.Messaging_Channel_Asset: SymbolType.channel,
                  SelectionOption.Channel: SymbolType.channel,
                }[name])) ??
          {
            SelectionOption.Restricted_Symbol:
                Icons.attach_money_rounded, //, color: Colors.black),
            SelectionOption.Main_Asset:
                MdiIcons.plusCircle, //, color: Color(0xDE000000)),
            SelectionOption.Restricted_Asset:
                MdiIcons.plusCircle, //, color: Color(0xDE000000)),
            SelectionOption.Qualifier_Asset:
                MdiIcons.plusCircle, //, color: Color(0xDE000000)),
            SelectionOption.Admin_Asset:
                MdiIcons.plusCircle, //, color: Color(0xDE000000)),
            SelectionOption.Main:
                MdiIcons.circle, //, color: Color(0xDE000000)),
            SelectionOption.Restricted:
                MdiIcons.lock, //, color: Color(0xDE000000)),
            SelectionOption.NFT_Asset:
                MdiIcons.plusCircle, //, color: Color(0xDE000000)),
            SelectionOption.Qualifier:
                MdiIcons.pound, //, color: Color(0xDE000000)),
            SelectionOption.Admin:
                MdiIcons.crownCircle, //, color: Color(0xDE000000)),
            SelectionOption.Sub_Asset:
                MdiIcons.plusCircle, //, color: Color(0xDE000000)),
            SelectionOption.NFT:
                MdiIcons.plusCircle, //, color: Color(0xDE000000)),
            SelectionOption.Messaging_Channel_Asset:
                MdiIcons.plusCircle, //, color: Color(0xDE000000)),
            SelectionOption.Dec8:
                MdiIcons.numeric8Circle, //, color: Colors.black),
            SelectionOption.Dec7:
                MdiIcons.numeric7Circle, //, color: Colors.black),
            SelectionOption.Dec6:
                MdiIcons.numeric6Circle, //, color: Colors.black),
            SelectionOption.Dec5:
                MdiIcons.numeric5Circle, //, color: Colors.black),
            SelectionOption.Dec4:
                MdiIcons.numeric4Circle, //, color: Colors.black),
            SelectionOption.Dec3:
                MdiIcons.numeric3Circle, //, color: Colors.black),
            SelectionOption.Dec2:
                MdiIcons.numeric2Circle, //, color: Colors.black),
            SelectionOption.Dec1:
                MdiIcons.numeric1Circle, //, color: Colors.black),
            SelectionOption.Dec0:
                MdiIcons.numeric0Circle, //, color: Colors.black),
            SelectionOption.Change: Icons.add_rounded, //, color: Colors.black),
            SelectionOption.Bug:
                Icons.bug_report_rounded, //, color: Colors.black),
            SelectionOption.Reissue: Icons.refresh_rounded,
            SelectionOption.Issue_Dividend: MdiIcons.handCoin,
          }[name] ??
          MdiIcons.information,
      color: {
            SelectionOption.Change: AppColors.primary,
            SelectionOption.Bug: AppColors.primary,
          }[name] ??
          AppColors.primary);

  Widget walletItem(Wallet wallet, TextEditingController controller) =>
      ListTile(
          visualDensity: VisualDensity.compact,
          onTap: () {
            Navigator.pop(context);
            controller.text = wallet.name;
          },
          leading: const Icon(
            Icons.account_balance_wallet_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          title:
              Text(wallet.name, style: Theme.of(context).textTheme.bodyText1));

  Widget walletItemAll(TextEditingController controller) => ListTile(
      visualDensity: VisualDensity.compact,
      onTap: () {
        Navigator.pop(context);
        controller.text = 'All Wallets';
      },
      leading: const Icon(
        Icons.account_balance_wallet_rounded,
        color: AppColors.primary,
        size: 24,
      ),
      title: Text('All Wallets', style: Theme.of(context).textTheme.bodyText1));

  Widget parentItem(String name) => ListTile(
      visualDensity: VisualDensity.compact,
      onTap: () {
        Navigator.pop(context);
        streams.create.form.add(GenericCreateForm.merge(
          form: streams.create.form.value,
          parent: name,
        ));
      },
      leading: components.icons.assetAvatar(name, height: 24, width: 24),
      title: Text(name, style: Theme.of(context).textTheme.bodyText1));

  Widget item(
    SelectionOption name, {
    Widget? title,
    VoidCallback? behavior,
    String? value,
    bool useCreateLeads = false,
  }) =>
      ListTile(
        visualDensity: VisualDensity.compact,
        onTap: () {
          Navigator.pop(context);
          (behavior ?? () {})();
        },
        leading: symbol == null
            ? useCreateLeads
                ? createLeads(name)
                : leads(name)
            : components.icons.assetAvatar(
                {
                  SelectionOption.Main: symbol,
                  SelectionOption.Sub: symbol,
                  SelectionOption.Sub_Admin: symbol,
                  SelectionOption.Admin: '$symbol!',
                  SelectionOption.Restricted: '\$$symbol',
                  SelectionOption.Restricted_Admin: '\$$symbol',
                  SelectionOption.Qualifier: '#$symbol',
                  SelectionOption.Sub_Qualifier: '#$symbol',
                  SelectionOption.NFT: symbol,
                  SelectionOption.Channel: symbol,
                }[name]!,
                size: 24),
        title: title ??
            Text(asString(name), style: Theme.of(context).textTheme.bodyText1),
        trailing: value != null
            ? Text(value,
                style: Theme.of(context).textTheme.bodyText2!.copyWith(
                    fontWeight: FontWeights.bold,
                    letterSpacing: 0.1,
                    color: AppColors.black60))
            : null,
      );

  Widget restrictedItem(String name) => item(
        SelectionOption.Restricted_Symbol,
        title: Text(name,
            style: Theme.of(context).textTheme.bodyText2!.copyWith(
                fontWeight: FontWeights.bold,
                letterSpacing: 0.1,
                color: AppColors.black60)),
        behavior: () => streams.create.form.add(GenericCreateForm.merge(
          form: streams.create.form.value,
          name: name,
        )),
      );

  Widget decimalItem(
    SelectionOption name, {
    String? prefix,
    bool reissue = false,
  }) =>
      item(
        name,
        title: Row(children: <Widget>[
          Text(prefix ?? '0',
              style: Theme.of(context).textTheme.bodyText2!.copyWith(
                  fontWeight: FontWeights.bold,
                  letterSpacing: 0.1,
                  color: AppColors.black60)),
          Text(
            {
              SelectionOption.Dec8: '.${'0' * 8}',
              SelectionOption.Dec7: '.${'0' * 7}',
              SelectionOption.Dec6: '.${'0' * 6}',
              SelectionOption.Dec5: '.${'0' * 5}',
              SelectionOption.Dec4: '.${'0' * 4}',
              SelectionOption.Dec3: '.${'0' * 3}',
              SelectionOption.Dec2: '.${'0' * 2}',
              SelectionOption.Dec1: '.${'0' * 1}',
              SelectionOption.Dec0: '',
            }[name]!,
            style: Theme.of(context).textTheme.bodyText2!.copyWith(
                fontWeight: FontWeights.bold,
                letterSpacing: 0.1,
                color: AppColors.primary),
          )
        ]),
        behavior: reissue
            ? () => streams.reissue.form.add(GenericReissueForm.merge(
                  form: streams.reissue.form.value,
                  decimal: int.parse(StringCharactersExtension(asString(name))
                      .characters
                      .last),
                ))
            : () => streams.create.form.add(GenericCreateForm.merge(
                  form: streams.create.form.value,
                  decimal: int.parse(StringCharactersExtension(asString(name))
                      .characters
                      .last),
                )),
      );

  Widget createItem(SelectionOption name) => item(
        name,
        behavior: () => Navigator.pushNamed(
          components.routes.routeContext!,
          '/create/${asString(name).toLowerCase()}',
          arguments: {'symbol': asString(name)},
        ),
        useCreateLeads: true, // modalSet == SelectionSet.Create
      );

  Widget assetItem(SelectionOption name) => item(
        name,
        behavior: () => Navigator.pushNamed(
          components.routes.routeContext!,
          '/create/${asString(name).toLowerCase()}',
          //{
          //  SelectionOption.Main: 'main',
          //  SelectionOption.Restricted: 'restricted',
          //  SelectionOption.Qualifier: 'qualifier',
          //}[name]!,
          arguments: {'symbol': asString(name)},
        ),
      );

  Widget subAssetItem(SelectionOption name) => item(
        name,
        behavior: () => Navigator.pushNamed(
          components.routes.routeContext!,
          '/create/${{
            SelectionOption.Sub_Asset: 'main',
            SelectionOption.NFT: 'nft',
            SelectionOption.Messaging_Channel_Asset: 'channel',
          }[name]!}',
          arguments: {'symbol': asString(name)},
        ),
      );

  Future<void> produceModal(List<Widget> items) async {
    await showModalBottomSheet<void>(
        context: context,
        elevation: 1,
        isScrollControlled: true,
        barrierColor: AppColors.black38,
        shape: shapes.topRounded8,
        builder: (BuildContext context) {
          streams.app.scrim.add(true);
          final DraggableScrollableController draggableScrollController =
              DraggableScrollableController();
          final double minExtent =
              min((items.length * 52 + 16).ofMediaHeight(context), 0.5);
          final double initialExtent = minExtent;
          double maxExtent = (items.length * 52 + 16).ofMediaHeight(context);
          maxExtent = min(1.0, max(minExtent, maxExtent));
          return DraggableScrollableSheet(
            controller: draggableScrollController,
            expand: false,
            initialChildSize: initialExtent,
            minChildSize: minExtent,
            maxChildSize: maxExtent,
            builder: (BuildContext context, ScrollController scrollController) {
              return FrontCurve(
                  child: ListView(
                shrinkWrap: true,
                controller: scrollController,
                children: <Widget>[
                  ...<Widget>[const SizedBox(height: 8)],
                  ...items,
                  ...<Widget>[const SizedBox(height: 8)],
                ],
              ));
            },
          );
        }).then((_) => streams.app.scrim.add(false));
  }

  Future<void> build({
    List<String>? holdingNames,
    String? decimalPrefix,
    TextEditingController? controller,
    int? minDecimal,
  }) async {
    // wait for keyboard to drop (if you don't it has issues on ios)
    while (streams.app.keyboard.value != KeyboardStatus.down) {
      // drop keyboard incase it's up
      try {
        FocusScope.of(context).unfocus();
      } catch (e) {}
      await Future<void>.delayed(const Duration(milliseconds: 600));
    }
    if (modalSet == SelectionSet.Wallets) {
      await produceModal(<Widget>[
            if (pros.wallets.length > 1) walletItemAll(controller!)
          ] +
          <Widget>[
            for (Wallet wallet in pros.wallets) walletItem(wallet, controller!)
          ]);
    } else if (modalSet == SelectionSet.Admins) {
      produceModal(
        <Widget>[
          for (String name in holdingNames ?? <String>[]) restrictedItem(name)
        ],
      );
    } else if (modalSet == SelectionSet.Parents) {
      produceModal(<Widget>[
        for (String holding in holdingNames ?? <String>[]) parentItem(holding)
      ]);
    } else if (modalSet == SelectionSet.Decimal) {
      produceModal(
        <Widget>[
          for (SelectionOption name
              in names.sublist(0, names.length - (minDecimal ?? 0)))
            decimalItem(name,
                prefix: decimalPrefix, reissue: minDecimal != null)
        ],
      );
    } else if (modalSet == SelectionSet.Create) {
      produceModal(
        <Widget>[for (SelectionOption name in names) createItem(name)],
      );
    } else if (modalSet == SelectionSet.Sub_Asset) {
      symbolColors = streams.app.manage.asset.value;
      produceModal(
        <Widget>[
          for (SelectionOption name in names) createItem(name)
        ], //subAssetItem(name)],
      );
    } else {
      if (names.length == behaviors.length && names.length == values.length) {
        if (symbol == null) {
          produceModal(
            <Widget>[
              for (List<Object> namedBehaviorValue in <List<Object>>[
                for (int i = 0; i < names.length; i += 1)
                  <Object>[names[i], behaviors[i], values[i]]
              ])
                item(namedBehaviorValue[0] as SelectionOption,
                    behavior: namedBehaviorValue[1] as VoidCallback,
                    value: namedBehaviorValue[2] as String)
            ],
          );
        } else {
          produceModal(
            <Widget>[
              for (List<Object> namedBehaviorValue in <List<Object>>[
                for (int i = 0; i < names.length; i += 1)
                  <Object>[names[i], behaviors[i], values[i]]
              ])
                item(namedBehaviorValue[0] as SelectionOption,
                    behavior: namedBehaviorValue[1] as VoidCallback,
                    value: namedBehaviorValue[2] as String)
            ],
          );
        }
      } else if (names.length == behaviors.length) {
        produceModal(
          <Widget>[
            for (List<Object> namedBehavior in <List<Object>>[
              for (int i = 0; i < names.length; i += 1)
                <Object>[names[i], behaviors[i]]
            ])
              item(namedBehavior[0] as SelectionOption,
                  behavior: namedBehavior[1] as VoidCallback)
          ],
        );
      } else {
        produceModal(
          <Widget>[for (SelectionOption name in names) item(name)],
        );
      }
    }
  }
}

class SimpleSelectionItems {
  SimpleSelectionItems(this.context, {required this.items, this.then});
  final BuildContext context;
  late List<Widget> items;
  late void Function()? then;

  Future<void> build() async {
    await showModalBottomSheet<void>(
        context: context, //components.routes.mainContext!,
        elevation: 1,
        isScrollControlled: true,
        barrierColor: AppColors.black38,
        shape: shapes.topRounded8,
        builder: (BuildContext context) {
          if (streams.app.scrim.value == false) {
            streams.app.scrim.add(true);
          }
          final DraggableScrollableController draggableScrollController =
              DraggableScrollableController();
          final double minExtent =
              min((items.length * 52 + 16 + 24).ofMediaHeight(context), 0.5);
          final double initialExtent = minExtent;
          double maxExtent = (items.length * 52 + 16).ofMediaHeight(context);
          maxExtent = min(1.0, max(minExtent, maxExtent));

          /// failed attempt to use set state
          //return StatefulBuilder(builder: (BuildContext context,
          //    StateSetter setState /*You can rename this!*/) {
          return DraggableScrollableSheet(
            controller: draggableScrollController,
            expand: false,
            initialChildSize: initialExtent,
            minChildSize: minExtent,
            maxChildSize: maxExtent,
            builder: (BuildContext context, ScrollController scrollController) {
              return FrontCurve(
                  alignment: Alignment.topCenter,
                  child: ListView(
                    shrinkWrap: true,
                    controller: scrollController,
                    children: <Widget>[
                      ...[const SizedBox(height: 8)],
                      ...items,
                      ...[const SizedBox(height: 8)],
                    ],
                  ));
            },
          );
          //});
        }).then((value) {
      if (streams.app.scrim.value == true) {
        streams.app.scrim.add(false);
      }
      if (then != null) {
        then!();
      }
    });
  }
}

class SimpleScrim {
  SimpleScrim(this.context, {this.then});
  final BuildContext context;
  late void Function()? then;

  Future<void> build() async {
    await showModalBottomSheet<void>(
        context: components.routes.routeContext!,
        elevation: 1,
        isScrollControlled: true,
        barrierColor: AppColors.black38,
        shape: shapes.topRounded8,
        builder: (BuildContext context) {
          if (streams.app.scrim.value == false) {
            streams.app.scrim.add(true);
          }
          return Container(height: 0);
        }).then((value) {
      if (streams.app.scrim.value == true) {
        streams.app.scrim.add(false);
      }
      if (then != null) {
        then!();
      }
    });
  }
}
