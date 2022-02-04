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

enum SelectionSet { Fee, Holdings, Create, Manage, Asset, Sub_Asset }
enum SelectionOption {
  Fast,
  Standard,
  Slow,
  Holdings,
  Main_Asset,
  Restricted_Asset,
  Qualifier_Asset,
  Admin_Asset,
  Main,
  Restricted,
  Qualifier,
  Admin,
  Sub_Asset,
  NFT,
  Messaging_Channel_Asset,
}

class SelectionItems {
  late List<SelectionOption> names;
  late List<VoidCallback> behaviors;
  late SelectionSet? modalSet;
  final BuildContext context;

  SelectionItems(
    this.context, {
    List<SelectionOption>? names,
    List<VoidCallback>? behaviors,
    SelectionSet? modalSet,
  }) {
    // handle the error here if we have to error.
    this.modalSet = modalSet;
    this.names = (names ??
            {
              SelectionSet.Holdings: [SelectionOption.Holdings],
              SelectionSet.Fee: [
                SelectionOption.Fast,
                SelectionOption.Standard,
                SelectionOption.Slow,
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
  }

  String asString(SelectionOption name) =>
      name.enumString.toTitleCase(underscoreAsSpace: true);

  Widget leads(SelectionOption name, {String? holding}) =>
      {
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

  Widget item(SelectionOption name, {VoidCallback? behavior}) => ListTile(
      visualDensity: VisualDensity.compact,
      onTap: () {
        Navigator.pop(context);
        (behavior ?? () {})();
      },
      leading: leads(name),
      title: Text(asString(name), style: Theme.of(context).choices));

  Widget feeItem(SelectionOption name) => item(
        name,
        behavior: () => streams.spend.form.add(SpendForm.merge(
          form: streams.spend.form.value,
          fee: asString(name),
        )),
      );

  Widget createItem(SelectionOption name) => item(
        name,
        behavior: () => Navigator.pushNamed(
          components.navigator.routeContext!,
          '/transaction/receive', // replace with correct form...
          //'/create/forms/${asString(name).toLowerCase}',
          arguments: {'symbol': asString(name)},
        ),
      );

  Widget assetItem(SelectionOption name) => item(
        name,
        behavior: () => Navigator.pushNamed(
          components.navigator.routeContext!,
          '/transaction/receive', // replace with correct view page...
          //'/manage/asset/${asString(name).toLowerCase}',
          arguments: {'symbol': asString(name)},
        ),
      );

  Widget subAssetItem(SelectionOption name) => item(
        name,
        behavior: () => Navigator.pushNamed(
          components.navigator.routeContext!,
          '/transaction/receive', // replace with correct view page...
          //'/manage/asset/${asString(name).toLowerCase}',
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

  void build({List<String>? holdingNames}) {
    if (modalSet == SelectionSet.Holdings) {
      produceModal(
        [for (var holding in holdingNames ?? []) holdingItem(holding)],
      );
    } else if (modalSet == SelectionSet.Fee) {
      produceModal([for (var name in names) feeItem(name)], tall: false);
    } else if (modalSet == SelectionSet.Create) {
      produceModal([for (var name in names) createItem(name)], tall: false);
    } else if (modalSet == SelectionSet.Sub_Asset) {
      produceModal([for (var name in names) subAssetItem(name)], tall: false);
    } else {
      if (names.length == behaviors.length) {
        produceModal([
          for (var namedBehavior in [
            for (var i = 0; i < names.length; i += 1) [names[i], behaviors[i]]
          ])
            item(namedBehavior[0] as SelectionOption,
                behavior: namedBehavior[1] as VoidCallback)
        ], tall: false);
      } else {
        produceModal([for (var name in names) item(name)], tall: false);
      }
    }
  }
}
