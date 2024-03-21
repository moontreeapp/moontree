import 'package:flutter/material.dart';
import 'package:moontree/cubits/cubit.dart';
import 'package:moontree/domain/concepts/sections.dart';
import 'package:moontree/services/services.dart' show screen; //, maestro;
import 'package:moontree/presentation/widgets/assets/icons.dart';

class NavbarSections extends StatelessWidget {
  final NavbarSection section;
  const NavbarSections({super.key, required this.section});

  @override
  Widget build(BuildContext context) => Container(
      height: screen.navbar.sectionsHeight,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //Expanded(
            //    child: GestureDetector(
            //        onTap: () => maestro.conduct(NavbarSection.wallet),
            //        child: NavbarIcons.wallet(section == NavbarSection.wallet))),
            //Expanded(
            //    child: GestureDetector(
            //        onTap: () => maestro.conduct(NavbarSection.send),
            //        child: NavbarIcons.send(section == NavbarSection.send))),
            //Expanded(
            //    child: GestureDetector(
            //        onTap: () => maestro.conduct(NavbarSection.recieve),
            //        child:
            //            NavbarIcons.recieve(section == NavbarSection.recieve))),
            //Expanded(
            //    child: GestureDetector(
            //        onTap: () => maestro.conduct(NavbarSection.manage),
            //        child:
            //            NavbarIcons.manage(section == NavbarSection.manage))),
            //Expanded(
            //    child: GestureDetector(
            //        onTap: () => maestro.conduct(NavbarSection.swap),
            //        child: NavbarIcons.swap(
            //          selected: section == NavbarSection.swap,
            //          photo: cubits.swap.state.image,
            //        ))),
          ]));
}
