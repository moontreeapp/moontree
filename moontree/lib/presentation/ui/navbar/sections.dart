import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moontree/domain/concepts/sections.dart';
import 'package:moontree/domain/utils/string.dart';
import 'package:moontree/presentation/theme/colors.dart';
import 'package:moontree/services/services.dart' show screen, maestro;
import 'package:moontree/presentation/theme/extensions.dart';
import 'package:moontree/presentation/widgets/assets/icons.dart';

class NavbarSections extends StatelessWidget {
  final NavbarSection section;
  const NavbarSections({super.key, required this.section});

  @override
  Widget build(BuildContext context) => Container(
      color: Colors.white,
      height: screen.navbar.height,
      alignment: Alignment.center,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                child: GestureDetector(
                    onTap: () => maestro.conduct(NavbarSection.wallet),
                    child: NavbarSectionButton(
                        section: NavbarSection.wallet,
                        selected: section == NavbarSection.wallet))),
            Expanded(
                child: GestureDetector(
                    onTap: () => maestro.conduct(NavbarSection.send),
                    child: NavbarSectionButton(
                        section: NavbarSection.send,
                        selected: section == NavbarSection.send))),
            Expanded(
                child: GestureDetector(
                    onTap: () => maestro.conduct(NavbarSection.receive),
                    child: NavbarSectionButton(
                        section: NavbarSection.receive,
                        selected: section == NavbarSection.receive))),
            Expanded(
                child: GestureDetector(
                    onTap: () => maestro.conduct(NavbarSection.mint),
                    child: NavbarSectionButton(
                        section: NavbarSection.mint,
                        selected: section == NavbarSection.mint))),
          ]));
}

class NavbarSectionButton extends StatelessWidget {
  final NavbarSection section;
  final bool selected;
  const NavbarSectionButton({
    super.key,
    required this.section,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) =>
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
            alignment: Alignment.center,
            child: SvgPicture.asset(
              '${NavbarIcons.base}/${section.name}${selected ? '-active' : ''}.${NavbarIcons.ext}',
              height: screen.navbar.iconHeight,
              width: screen.navbar.iconHeight,
              fit: BoxFit.contain,
              alignment: Alignment.center,
              //colorFilter: selected
              //    ? ColorFilter.mode(AppColors.primary, BlendMode.modulate)
              //    : null,
              colorFilter: ColorFilter.mode(Colors.black, BlendMode.modulate),
            )),
        Text(section.name.toTitleCase(),
            style: Theme.of(context)
                .textTheme
                .caption1!
                .copyWith(color: AppColors.black))
      ]);
}
