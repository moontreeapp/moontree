import 'package:flutter/material.dart';
import 'package:moontree/cubits/cubit.dart';
import 'package:moontree/domain/concepts/sections.dart';
import 'package:moontree/presentation/components/icons.dart';
import 'package:moontree/presentation/services/services.dart'
    show screen, maestro;

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
            Expanded(
                child: GestureDetector(
                    onTap: () => maestro.conduct(NavbarSection.home),
                    child: NavbarIcons.home(section == NavbarSection.home))),
            Expanded(
                child: GestureDetector(
                    onTap: () => maestro.conduct(NavbarSection.explore),
                    child:
                        NavbarIcons.explore(section == NavbarSection.explore))),
            Expanded(
                child: GestureDetector(
                    onTap: () => maestro.conduct(NavbarSection.create),
                    child:
                        NavbarIcons.create(section == NavbarSection.create))),
            Expanded(
                child: GestureDetector(
                    onTap: () => maestro.conduct(NavbarSection.crew),
                    child: NavbarIcons.crew(section == NavbarSection.crew))),
            Expanded(
                child: GestureDetector(
                    onTap: () => maestro.conduct(NavbarSection.profile),
                    child: NavbarIcons.profile(
                      selected: section == NavbarSection.profile,
                      photo: cubits.profile.state.image,
                    ))),
          ]));
}
