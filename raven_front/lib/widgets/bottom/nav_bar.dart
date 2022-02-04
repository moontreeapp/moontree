import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/app.dart';
import 'package:raven_back/streams/streams.dart';
import 'package:raven_front/backdrop/backdrop.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/widgets/widgets.dart';

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
            // we will need to make these buttons dependant upon the navigation
            // of the front page through streams but for now, we'll show they
            // can changed based upon whats selected:
            selected == 'wallet'
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      actionButton(name: 'send', link: '/transaction/send'),
                      SizedBox(width: 16),
                      actionButton(
                          name: 'receive', link: '/transaction/receive'),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      actionButton(
                          name: 'create', onPressed: _produceCreateModal),
                      SizedBox(width: 16),
                      actionButton(
                          name: 'manage',
                          onPressed: () {/* bring up options */}),
                    ],
                  ),
            Padding(
                padding: EdgeInsets.only(left: 32, right: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    sectorIcon(name: 'wallet'),
                    sectorIcon(name: 'create'),
                    sectorIcon(name: 'swap'),
                  ],
                ))
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

  Widget actionButton({
    required String name,
    String? link,
    VoidCallback? onPressed,
  }) =>
      Expanded(
          child: Container(
              height: 40,
              child: OutlinedButton.icon(
                onPressed: link != null
                    ? () {
                        Backdrop.of(components.navigator.routeContext!)
                            .concealBackLayer();
                        Navigator.of(components.navigator.routeContext!)
                            .pushNamed(link);
                      }
                    : onPressed ?? () {},
                icon: Icon({
                  'send': MdiIcons.arrowTopRightThick,
                  'receive': MdiIcons.arrowBottomLeftThick,
                  'create': MdiIcons.plusCircle,
                  'manage': MdiIcons.crown,
                }[name]!),
                label: Text(name.toUpperCase()),
                style: components.styles.buttons.bottom(context),
              )));

  Widget sectorIcon({required String name}) => IconButton(
        onPressed: () {
          setState(() {
            selected = name;
            streams.app.context.add({
              'wallet': AppContext.wallet,
              'create': AppContext.manage,
              'swap': AppContext.wallet,
            }[name]!);
          });
        },
        icon: Icon({
          'wallet': MdiIcons.wallet,
          'create': MdiIcons.plusCircle,
          'swap': MdiIcons.swapHorizontalBold,
        }[name]!),
        iconSize: selected == name ? 30 : 24,
        color: selected == name ? Color(0xFF5C6BC0) : Color(0x995C6BC0),
      );

  void _produceCreateModal() {
    SelectionItems(context, modalSet: SelectionSet.Create).build();
  }
}
