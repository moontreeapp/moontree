/// In order to extend the scrim to the entire page, including the app bar...
/// this should probably be a permanent fixture on the main scaffold,
/// which changes based upon a page or messages from a stream... idk, but,
/// for now we'll put it here because it'll be easy to move to main if we want.

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/extensions/object.dart';
import 'package:raven_back/extensions/string.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:raven_front/components/components.dart';

enum SelectionOptions { Fast, Standard, Slow, Holdings }

class SelectionItems {
  final List<SelectionOptions> names;
  final BuildContext context;

  const SelectionItems(this.context, {required this.names});

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
      }[name] ??
      Icon(MdiIcons.speedometerMedium, color: Color(0x99000000));

  Widget item(SelectionOptions name) => ListTile(
      visualDensity: VisualDensity.compact,
      onTap: () {
        print(asString(name));
        streams.app.spending.fee.add(asString(name));
        Navigator.pop(context);
      },
      leading: leads(name),
      title: Text(asString(name), style: Theme.of(context).choices));

  Widget holdingItem(String name) => ListTile(
      visualDensity: VisualDensity.compact,
      onTap: () {
        print(name);
        streams.app.spending.symbol.add(name);
        Navigator.pop(context);
      },
      leading: components.icons.assetAvatar(name, height: 24, width: 24),
      title: Text(name, style: Theme.of(context).choices));

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
            // it seems like the screen thinks it's 210 larger than it is...
            // something in the main scaffold is causing this issue...
            height:
                tall ? (MediaQuery.of(context).size.height + 394) / 2 : null,
            child: ListView(shrinkWrap: true, children: <Widget>[
              ...[SizedBox(height: 8)],
              ...items,
              ...[SizedBox(height: 8)],
              ...[SizedBox(height: 201)], // workaround...
            ])));
  }

  void build({List<String>? holdingNames}) {
    if (names.contains(SelectionOptions.Holdings)) {
      produceModal(
        [for (var holding in holdingNames ?? []) holdingItem(holding)],
      );
    } else {
      produceModal([for (var name in names) item(name)], tall: false);
    }
  }
}
