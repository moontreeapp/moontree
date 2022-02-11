/// In order to extend the scrim to the entire page, including the app bar...
/// this should probably be a permanent fixture on the main scaffold,
/// which changes based upon a page or messages from a stream... idk, but,
/// for now we'll put it here because it'll be easy to move to main if we want.

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/spend.dart';
import 'package:raven_back/extensions/object.dart';
import 'package:raven_back/extensions/string.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_back/streams/create.dart';

enum SelectionSet {
  Fee,
  Decimal,
  Holdings,
  Admins,
  Create,
  Manage,
  Asset,
  Sub_Asset
}
enum SelectionOption {
  // list of my assets
  Holdings,
  Admins,

  // for admins
  Restricted_Symbol,

  // fee
  Fast,
  Standard,
  Slow,

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
}

class SelectionItems {
  late List<SelectionOption> names;
  late List<VoidCallback> behaviors;
  late List<String> values;
  late SelectionSet? modalSet;
  final BuildContext context;

  SelectionItems(
    this.context, {
    List<SelectionOption>? names,
    List<VoidCallback>? behaviors,
    List<String>? values,
    SelectionSet? modalSet,
  }) {
    // handle the error here if we have to error.
    this.modalSet = modalSet;
    this.names = (names ??
            {
              SelectionSet.Holdings: [SelectionOption.Holdings],
              SelectionSet.Admins: [SelectionOption.Admins],
              SelectionSet.Fee: [
                SelectionOption.Fast,
                SelectionOption.Standard,
                SelectionOption.Slow,
              ],
              SelectionSet.Decimal: [
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
              SelectionSet.Create: [
                SelectionOption.Main,
                SelectionOption.Restricted,
                SelectionOption.Qualifier,
              ],
              SelectionSet.Sub_Asset: [
                SelectionOption.Sub_Asset,
                SelectionOption.NFT,
                SelectionOption.Messaging_Channel_Asset,
              ],
            }[modalSet]) ??
        [];
    this.behaviors = behaviors ?? [];
    this.values = values ?? [];
  }

  String asString(SelectionOption name) =>
      name.enumString.toTitleCase(underscoreAsSpace: true);

  Widget leads(SelectionOption name, {String? holding}) =>
      {
        SelectionOption.Restricted_Symbol:
            Icon(Icons.attach_money_rounded, color: Colors.black),
        SelectionOption.Fast:
            Icon(MdiIcons.speedometer, color: Color(0x99000000)),
        SelectionOption.Standard:
            Icon(MdiIcons.speedometerMedium, color: Color(0x99000000)),
        SelectionOption.Slow:
            Icon(MdiIcons.speedometerSlow, color: Color(0x99000000)),
        SelectionOption.Main_Asset:
            Icon(MdiIcons.plusCircle, color: Color(0xDE000000)),
        SelectionOption.Restricted_Asset:
            Icon(MdiIcons.plusCircle, color: Color(0xDE000000)),
        SelectionOption.Qualifier_Asset:
            Icon(MdiIcons.plusCircle, color: Color(0xDE000000)),
        SelectionOption.Admin_Asset:
            Icon(MdiIcons.plusCircle, color: Color(0xDE000000)),
        SelectionOption.Main: Icon(MdiIcons.circle, color: Color(0xDE000000)),
        SelectionOption.Restricted:
            Icon(MdiIcons.lock, color: Color(0xDE000000)),
        SelectionOption.NFT_Asset:
            Icon(MdiIcons.plusCircle, color: Color(0xDE000000)),
        SelectionOption.Qualifier:
            Icon(MdiIcons.plusCircle, color: Color(0xDE000000)),
        SelectionOption.Admin:
            Icon(MdiIcons.crownCircle, color: Color(0xDE000000)),
        SelectionOption.Sub_Asset:
            Icon(MdiIcons.plusCircle, color: Color(0xDE000000)),
        SelectionOption.NFT:
            Icon(MdiIcons.plusCircle, color: Color(0xDE000000)),
        SelectionOption.Messaging_Channel_Asset:
            Icon(MdiIcons.plusCircle, color: Color(0xDE000000)),
        SelectionOption.Dec8:
            Icon(MdiIcons.numeric8Circle, color: Colors.black),
        SelectionOption.Dec7:
            Icon(MdiIcons.numeric7Circle, color: Colors.black),
        SelectionOption.Dec6:
            Icon(MdiIcons.numeric6Circle, color: Colors.black),
        SelectionOption.Dec5:
            Icon(MdiIcons.numeric5Circle, color: Colors.black),
        SelectionOption.Dec4:
            Icon(MdiIcons.numeric4Circle, color: Colors.black),
        SelectionOption.Dec3:
            Icon(MdiIcons.numeric3Circle, color: Colors.black),
        SelectionOption.Dec2:
            Icon(MdiIcons.numeric2Circle, color: Colors.black),
        SelectionOption.Dec1:
            Icon(MdiIcons.numeric1Circle, color: Colors.black),
        SelectionOption.Dec0:
            Icon(MdiIcons.numeric0Circle, color: Colors.black),
      }[name] ??
      Icon(MdiIcons.information, color: Color(0x99000000));

  Widget holdingItem(String name) => ListTile(
      visualDensity: VisualDensity.compact,
      onTap: () {
        Navigator.pop(context);
        streams.spend.form.add(SpendForm.merge(
          form: streams.spend.form.value,
          symbol: name,
        ));
      },
      leading: components.icons.assetAvatar(
        name == 'Ravencoin' ? 'RVN' : name,
        height: 24,
        width: 24,
      ),
      title: Text(name, style: Theme.of(context).choices));

  Widget item(
    SelectionOption name, {
    Widget? title,
    VoidCallback? behavior,
    String? value,
  }) =>
      ListTile(
        visualDensity: VisualDensity.compact,
        onTap: () {
          Navigator.pop(context);
          (behavior ?? () {})();
        },
        leading: leads(name),
        title: title ?? Text(asString(name), style: Theme.of(context).choices),
        trailing: value != null
            ? Text(value, style: Theme.of(context).choices)
            : null,
      );

  Widget restrictedItem(String name) => item(
        SelectionOption.Restricted_Symbol,
        title: Text(name, style: Theme.of(context).choices),
        behavior: () => streams.create.form.add(GenericCreateForm.merge(
          form: streams.create.form.value,
          name: name,
        )),
      );

  Widget feeItem(SelectionOption name) => item(
        name,
        behavior: () => streams.spend.form.add(SpendForm.merge(
          form: streams.spend.form.value,
          fee: asString(name),
        )),
      );

  Widget decimalItem(SelectionOption name, {String? prefix}) => item(
        name,
        title: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Text(prefix ?? '0', style: Theme.of(context).choices),
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
            style: Theme.of(context).choicesBlue,
          ),
        ]),
        behavior: () => streams.create.form.add(GenericCreateForm.merge(
          form: streams.create.form.value,
          decimal: StringCharactersExtension(asString(name)).characters.last,
        )),
      );

  Widget createItem(SelectionOption name) => item(
        name,
        behavior: () => Navigator.pushNamed(
          components.navigator.routeContext!,
          '/create/' + asString(name).toLowerCase(),
          //{
          //  SelectionOption.Main: 'main',
          //  SelectionOption.Restricted: 'restricted',
          //  SelectionOption.Qualifier: 'qualifier',
          //}[name]!,
          arguments: {'symbol': asString(name)},
        ),
      );

  Widget assetItem(SelectionOption name) => item(
        name,
        behavior: () => Navigator.pushNamed(
          components.navigator.routeContext!,
          '/create/' + asString(name).toLowerCase(),
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
          components.navigator.routeContext!,
          '/create/' +
              {
                SelectionOption.Sub_Asset: 'main',
                SelectionOption.NFT: 'nft',
                SelectionOption.Messaging_Channel_Asset: 'channel',
              }[name]!,
          arguments: {'symbol': asString(name)},
        ),
      );

  void produceModal(List items, {bool tall = true}) {
    showModalBottomSheet<void>(
        context: context,
        enableDrag: true,
        elevation: 1,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.0), topRight: Radius.circular(8.0))),
        builder: (BuildContext context) => Container(
            height: tall ? (MediaQuery.of(context).size.height) / 2 : null,
            child: ListView(shrinkWrap: true, children: <Widget>[
              ...[SizedBox(height: 8)],
              ...items,
              ...[SizedBox(height: 8)],
            ])));
  }

  void build({List<String>? holdingNames, String? decimalPrefix}) {
    if (modalSet == SelectionSet.Holdings) {
      produceModal(
        [for (String holding in holdingNames ?? []) holdingItem(holding)],
      );
    } else if (modalSet == SelectionSet.Admins) {
      produceModal(
          [for (String name in holdingNames ?? []) restrictedItem(name)],
          tall: false);
    } else if (modalSet == SelectionSet.Fee) {
      produceModal([for (SelectionOption name in names) feeItem(name)],
          tall: false);
    } else if (modalSet == SelectionSet.Decimal) {
      produceModal([
        for (SelectionOption name in names)
          decimalItem(name, prefix: decimalPrefix)
      ], tall: false);
    } else if (modalSet == SelectionSet.Create) {
      produceModal([for (SelectionOption name in names) createItem(name)],
          tall: false);
    } else if (modalSet == SelectionSet.Sub_Asset) {
      produceModal([for (SelectionOption name in names) subAssetItem(name)],
          tall: false);
    } else {
      if (names.length == behaviors.length && names.length == values.length) {
        produceModal([
          for (var namedBehavior in [
            for (var i = 0; i < names.length; i += 1)
              [names[i], behaviors[i], values[i]]
          ])
            item(namedBehavior[0] as SelectionOption,
                behavior: namedBehavior[1] as VoidCallback,
                value: namedBehavior[2] as String)
        ], tall: false);
      } else if (names.length == behaviors.length) {
        produceModal([
          for (var namedBehavior in [
            for (var i = 0; i < names.length; i += 1) [names[i], behaviors[i]]
          ])
            item(namedBehavior[0] as SelectionOption,
                behavior: namedBehavior[1] as VoidCallback)
        ], tall: false);
      } else {
        produceModal([for (SelectionOption name in names) item(name)],
            tall: false);
      }
    }
  }
}
