import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/streams.dart';
import 'package:raven_front/backdrop/backdrop.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/extensions.dart';

class NavBar extends StatefulWidget {
  NavBar({Key? key}) : super(key: key);

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  late String selected = 'wallet';

  @override
  Widget build(BuildContext context) => Container(
        height: 118,
        padding: EdgeInsets.only(left: 16, right: 16),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                actionButton(name: 'send', link: '/transaction/send'),
                SizedBox(width: 16),
                actionButton(name: 'receive', link: '/transaction/receive'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                sectorIcon(name: 'wallet'),
                sectorIcon(name: 'create'),
                sectorIcon(name: 'manage'),
                sectorIcon(name: 'swap'),
              ],
            )
          ],
        ),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                  color: const Color(0x33000000),
                  offset: Offset(0, 5),
                  blurRadius: 5),
              BoxShadow(
                  color: const Color(0x1F000000),
                  offset: Offset(0, 3),
                  blurRadius: 14),
              BoxShadow(
                  color: const Color(0x3D000000),
                  offset: Offset(0, 8),
                  blurRadius: 10)
            ]),
      );

  Widget actionButton({required String name, required String link}) => Expanded(
          child: OutlinedButton.icon(
        onPressed: () {
          Backdrop.of(components.navigator.routeContext!).concealBackLayer();
          Navigator.of(components.navigator.routeContext!).pushNamed(link);
        },
        icon: Icon({
          'send': MdiIcons.arrowTopRightThick,
          'receive': MdiIcons.arrowBottomLeftThick,
        }[name]!),
        label: Text(name.toUpperCase()),
        style: components.styles.buttons.bottom(context),
      ));

  Widget sectorIcon({required String name}) => IconButton(
        onPressed: () {
          setState(() {
            selected = name;
          });
        },
        icon: Icon({
          'wallet': MdiIcons.wallet,
          'create': MdiIcons.plusCircle,
          'manage': MdiIcons.crown,
          'swap': MdiIcons.swapHorizontalBold,
        }[name]!),
        iconSize: selected == name ? 30 : 24,
        color: selected == name ? Color(0xFF5C6BC0) : Color(0x995C6BC0),
      );
}
