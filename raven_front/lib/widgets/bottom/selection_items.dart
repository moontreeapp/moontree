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

enum SelectionSet { Fee, Holdings, Create, Manage, Asset }
enum SelectionOptions {
  Fast,
  Standard,
  Slow,
  Holdings,
  Main,
  Restricted,
  Qualifier,
}

class SelectionItems {
  late List<SelectionOptions> names;
  late List<VoidCallback> behaviors;
  late SelectionSet? modalSet;
  final BuildContext context;

  SelectionItems(
    this.context, {
    List<SelectionOptions>? names,
    List<VoidCallback>? behaviors,
    SelectionSet? modalSet,
  }) {
    // handle the error here if we have to error.
    this.modalSet = modalSet;
    this.names = (names ??
            {
              SelectionSet.Holdings: [SelectionOptions.Holdings],
              SelectionSet.Fee: [
                SelectionOptions.Fast,
                SelectionOptions.Standard,
                SelectionOptions.Slow,
              ],
              SelectionSet.Create: [
                SelectionOptions.Main,
                SelectionOptions.Restricted,
                SelectionOptions.Qualifier,
              ],
            }[modalSet]) ??
        [];
    this.behaviors = behaviors ?? [];
  }

  String asString(SelectionOptions name) =>
      name.enumString.toTitleCase(underscoreAsSpace: true);

  Widget leads(SelectionOptions name, {String? holding}) =>
      {
        SelectionOptions.Fast:
            Icon(MdiIcons.speedometer, color: Color(0x99000000)),
        SelectionOptions.Standard:
            Icon(MdiIcons.speedometerMedium, color: Color(0x99000000)),
        SelectionOptions.Slow:
            Icon(MdiIcons.speedometerSlow, color: Color(0x99000000)),
        SelectionOptions.Main:
            Icon(MdiIcons.plusCircle, color: Color(0xDE000000)),
        SelectionOptions.Restricted:
            Icon(MdiIcons.plusCircle, color: Color(0xDE000000)),
        SelectionOptions.Qualifier:
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

  Widget item(SelectionOptions name, {VoidCallback? behavior}) => ListTile(
      visualDensity: VisualDensity.compact,
      onTap: () {
        Navigator.pop(context);
        (behavior ?? () {})();
      },
      leading: leads(name),
      title: Text(asString(name), style: Theme.of(context).choices));

  Widget feeItem(SelectionOptions name) => item(
        name,
        behavior: () => streams.spend.form.add(SpendForm.merge(
          form: streams.spend.form.value,
          fee: asString(name),
        )),
      );

  Widget createItem(SelectionOptions name) => item(
        name,
        behavior: () => Navigator.pushNamed(
          components.navigator.routeContext!,
          '/transaction/receive', // replace with correct form...
          //'/create/forms/${asString(name).toLowerCase}',
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
    } else {
      if (names.length == behaviors.length) {
        produceModal([
          for (var namedBehavior in [
            for (var i = 0; i < names.length; i += 1) [names[i], behaviors[i]]
          ])
            item(namedBehavior[0] as SelectionOptions,
                behavior: namedBehavior[1] as VoidCallback)
        ], tall: false);
      }
      produceModal([for (var name in names) item(name)], tall: false);
    }
  }
}
