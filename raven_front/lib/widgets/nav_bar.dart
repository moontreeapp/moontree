//import 'package:backdrop/backdrop.dart';
import 'package:raven_front/backdrop/backdrop.dart';
import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/streams.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/services/account.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:settings_ui/settings_ui.dart';

import 'package:raven_back/extensions/list.dart';
import 'package:raven_back/utils/database.dart' as ravenDatabase;

class NavBar extends StatefulWidget {
  NavBar({Key? key}) : super(key: key);

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  late String selected = 'wallet';
  List listeners = [];

  @override
  void initState() {
    super.initState();
    //listeners.add(streams.app.page.stream.listen((value) {
    //  if (value != pageTitle) {
    //    setState(() {
    //      pageTitle = value;
    //    });
    //  }
    //}));
  }

  @override
  void dispose() {
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
        height: 118,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                actionButton(name: 'send'),
                actionButton(name: 'receive'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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

  Widget sectorIcon({required String name}) => IconButton(
        onPressed: () {
          setState(() {
            selected = name;
          });
        },
        icon: Image(
          image: AssetImage(
              'assets/icons/$name/${name}_${selected == name ? '' : 'in'}active.png'),
          height: selected == name ? 30 : 24,
          width: selected == name ? 30 : 24,
        ),
      );

  Widget actionButton({required String name}) => OutlinedButton(
        onPressed: () {},
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image(
              image: AssetImage('assets/icons/$name/${name}_black.png'),
              height: 24,
              width: 24),
          SizedBox(width: 8),
          Text(name.toUpperCase())
        ]),
        style: ButtonStyle(
          fixedSize: MaterialStateProperty.all(Size(156, 40)),
          textStyle: MaterialStateProperty.all(Theme.of(context).navBarButton),
          foregroundColor: MaterialStateProperty.all(Color(0xDE000000)),
          side: MaterialStateProperty.all(BorderSide(
              color: Color(0xFF5C6BC0), width: 2, style: BorderStyle.solid)),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0))),
        ),
      );
}
