import 'package:flutter/services.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:flutter/material.dart';
import 'package:moontree/cubits/navbar/cubit.dart';
import 'package:moontree/presentation/layers/navbar/components/carousel.dart';
import 'package:moontree/presentation/layers/navbar/components/icons.dart';
import 'package:moontree/services/services.dart' show screen;
import 'package:moontree/cubits/cubit.dart';
import 'package:moontree/presentation/theme/extensions.dart';

/// contains the menu items: say, edit, search
class ExtendedNavbarMenuItems extends StatelessWidget {
  final void Function() exit;
  const ExtendedNavbarMenuItems({
    super.key,
    required this.exit,
  });

  void onSay() {
    if (cubits.navbar.state.extendedSelected == ExtendedNavbarItem.say) {
      // do nothing - somehow tell the focusNode not to close...
    } else {
      SystemChannels.textInput.invokeMethod('TextInput.show');
      cubits.navbar.update(
        extendedSelected: ExtendedNavbarItem.say,
        //selectedIndex: 0,
      );
      //cubits.navbar.state.scroll?.jumpTo(0);
    }
  }

  void onEdit() {
    if (cubits.navbar.state.extendedSelected != ExtendedNavbarItem.gallery) {
      // todo: set the first item as the thing they choose
      cubits.navbar.update(
        extendedSelected: ExtendedNavbarItem.gallery,
        //selectedIndex: 1,
      );
      //cubits.navbar.state.scroll?.jumpTo(screen.navbar.itemWidth);
    } else {
      exit();
    }
  }

  void onSearch() {
    if (cubits.navbar.state.extendedSelected != ExtendedNavbarItem.search) {
      // todo: set the first item as the thing they choose
      cubits.navbar.update(
        extendedSelected: ExtendedNavbarItem.search,
        //selectedIndex: 1,
      );
      //cubits.navbar.state.scroll?.jumpTo(screen.navbar.itemWidth);
    } else {
      exit();
    }
  }

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IgnorePointer(
              ignoring: cubits.navbar.state.extendedSelected ==
                  ExtendedNavbarItem.say,
              child: ExtendedNavbarMenuItem(
                padding: const EdgeInsets.only(top: 32, left: 16),
                alignment: Alignment.topLeft,
                onTap: onSay,
                extendedNavbarItem: ExtendedNavbarItem.say,
                selected: cubits.navbar.state.extendedSelected ==
                    ExtendedNavbarItem.say,
              )),
          ExtendedNavbarMenuItem(
            onTap: onSearch,
            extendedNavbarItem: ExtendedNavbarItem.search,
            selected: cubits.navbar.state.extendedSelected ==
                ExtendedNavbarItem.search,
          ),
          ExtendedNavbarMenuItem(
            padding: const EdgeInsets.only(top: 32, right: 16),
            alignment: Alignment.topRight,
            onTap: onEdit,
            extendedNavbarItem: ExtendedNavbarItem.gallery,
            selected: cubits.navbar.state.extendedSelected ==
                ExtendedNavbarItem.gallery,
          ),
        ],
      );
}

/// contains the menu items: say, gallery, search
class ExtendedNavbarMenuItem extends StatelessWidget {
  final void Function() onTap;
  final ExtendedNavbarItem extendedNavbarItem;
  final bool selected;
  final EdgeInsets padding;
  final Alignment alignment;
  const ExtendedNavbarMenuItem({
    super.key,
    required this.onTap,
    required this.extendedNavbarItem,
    this.selected = false,
    this.padding = const EdgeInsets.only(top: 16),
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) => Container(
      padding: padding,
      alignment: alignment,
      width: screen.navbar.itemWidth,
      height: 64,
      child: Stack(children: [
        GestureDetector(
            onTap: onTap,
            child: Container(
                height: 32,
                width: 32,
                child: ShadedIcon(
                    size: 30,
                    color: selected ? Colors.white : null,
                    iconData: extendedNavbarItem == ExtendedNavbarItem.say
                        ? Hicons.keyboard_bold
                        : extendedNavbarItem == ExtendedNavbarItem.gallery
                            ? Hicons.image_2_bold
                            : extendedNavbarItem == ExtendedNavbarItem.search
                                ? Hicons.happy_1_bold
                                : Hicons.keyboard_bold))),
        //import 'package:moontree/presentation/components/icons.dart';
        //iconPath: extendedNavbarItem == ExtendedNavbarItem.say
        //    ? selected ? HypyrIcons.keyboardLoc : HypyrIcons.keyboardInactLoc
        //    : extendedNavbarItem == ExtendedNavbarItem.edit
        //        ? selected ? HypyrIcons.editLoc : HypyrIcons.editInactLoc
        //        : extendedNavbarItem == ExtendedNavbarItem.search
        //            ? selected ? HypyrIcons.searchLoc : HypyrIcons.searchInactLoc
        //            : ''))),
        if (selected)
          SelectedIndicator(
            onTap: onTap,
            size: 32,
            strokeWidth: 2,
          ),
      ]));
}

/// contains the menu items: back, 'edit'
class ExtendedNavbarMenuEdit extends StatelessWidget {
  const ExtendedNavbarMenuEdit({super.key});

  void exitEdit() => cubits.navbar.update(edit: false);

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 32, left: 16),
            alignment: Alignment.topLeft,
            width: screen.navbar.itemWidth,
            height: 64,
            child: GestureDetector(
              onTap: exitEdit,
              child: Icon(
                Hicons.left_2_bold,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 16),
            alignment: Alignment.topCenter,
            width: screen.navbar.itemWidth,
            height: 64,
            child: Text('View',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: Colors.white)),
          ),
        ],
      );
}

/// contains the name of searching section
class ExtendedNavbarMenuSearch extends StatelessWidget {
  const ExtendedNavbarMenuSearch({super.key});

  void exitEdit() => cubits.navbar.update(edit: false);

  @override
  Widget build(BuildContext context) =>
      // use cubit...
      Container(
        padding: const EdgeInsets.only(top: 24),
        alignment: Alignment.topCenter,
        width: screen.navbar.itemWidth,
        height: 64,
        child: Text('Reactions',
            style:
                Theme.of(context).textTheme.h2!.copyWith(color: Colors.white)),
      );
}
