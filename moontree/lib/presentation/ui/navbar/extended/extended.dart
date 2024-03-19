import 'package:flutter/material.dart';
import 'package:moontree/cubits/navbar/cubit.dart';
import 'package:moontree/cubits/cubit.dart';
import 'package:moontree/presentation/utils/animation.dart' as animation;
import 'package:moontree/presentation/services/services.dart' show screen, back;
import 'package:moontree/presentation/layers/navbar/extended/menu.dart';
import 'package:moontree/presentation/layers/navbar/extended/sections/search.dart';

/// extended navbar that contains the carousel and the menu items
class ExtendedNavbarContents extends StatefulWidget {
  final double maxHeight;
  final ExtendedNavbarItem selected;
  const ExtendedNavbarContents({
    super.key,
    required this.maxHeight,
    required this.selected,
  });

  @override
  _ExtendedNavbarContentsState createState() => _ExtendedNavbarContentsState();
}

class _ExtendedNavbarContentsState extends State<ExtendedNavbarContents>
    with TickerProviderStateMixin {
  late AnimationController fadeController;

  @override
  void initState() {
    super.initState();
    fadeController = AnimationController(
      vsync: this,
      duration: animation.slideDuration,
    );
    fadeController.forward(from: 0);
    back.setFunction(exit);
  }

  @override
  void dispose() {
    fadeController.dispose();
    back.setFunction(null);
    super.dispose();
  }

  void exit() {
    setState(() {
      fadeController.reverse(from: 1.0).then((_) {
        cubits.navbar.mid();
      });
    });
  }

  void exitEdit() => cubits.navbar.update(edit: false);

  @override
  Widget build(BuildContext context) => FadeTransition(
      opacity: fadeController,
      child: Container(
          width: screen.width,
          height: widget.maxHeight,
          alignment: Alignment.topCenter,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                //if (cubits.navbar.state.edit)
                //  ExtendedNavbarMenuEdit()
                //else
                ExtendedNavbarMenuSearch(),
                SearchSection(exit: exit),
              ])));
}
