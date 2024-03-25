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
      width: screen.width,
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
                    onTap: () => maestro.conduct(NavbarSection.mint),
                    child: NavbarSectionButton(
                        section: NavbarSection.mint,
                        selected: section == NavbarSection.mint))),
            Expanded(
                child: GestureDetector(
                    onTap: () => maestro.conduct(NavbarSection.swap),
                    child: NavbarSectionButton(
                        section: NavbarSection.swap,
                        selected: section == NavbarSection.swap))),
          ]));
}

extension NavbarSectionPosition on NavbarSection {
  Alignment get alignment {
    switch (this) {
      case NavbarSection.wallet:
        return Alignment.centerRight;
      case NavbarSection.swap:
        return Alignment.centerLeft;
      default:
        return Alignment.center;
    }
  }

  EdgeInsets? get padding {
    switch (this) {
      case NavbarSection.wallet:
        return EdgeInsets.only(
            right: (screen.widthOneThird - screen.navbar.iconHeight) / 4.5);
      case NavbarSection.swap:
        return EdgeInsets.only(
            left: (screen.widthOneThird - screen.navbar.iconHeight) / 4.5);
      default:
        return null;
    }
  }
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
  Widget build(BuildContext context) => Container(
      color: Colors.transparent,
      alignment: section.alignment,
      padding: section.padding,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SvgPicture.asset(
          '${NavbarIcons.base}/${section.name}${selected ? '-active' : ''}.${NavbarIcons.ext}',
          height: screen.navbar.iconHeight,
          width: screen.navbar.iconHeight,
          fit: BoxFit.contain,
          alignment: Alignment.center,
          colorFilter: const ColorFilter.mode(Colors.black, BlendMode.modulate),
        ),
        Text(section.name.toTitleCase(),
            style: Theme.of(context)
                .textTheme
                .caption1!
                .copyWith(color: AppColors.black))
      ]));
}
