import 'package:flutter/material.dart';
import 'package:intersperse/intersperse.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/app.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/theme.dart';

class NavBar extends StatefulWidget {
  final Iterable<Widget> actionButtons;
  final bool includeSectors;

  NavBar({
    Key? key,
    required this.actionButtons,
    this.includeSectors = true,
  }) : super(key: key);

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height *
          ((widget.includeSectors ? 118 : 72) / 760),
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 0),
      width: MediaQuery.of(context).size.width,
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
        ],
      ),
      child: Column(
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // we will need to make these buttons dependant upon the navigation
          // of the front page through streams but for now, we'll show they
          // can changed based upon whats selected:
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:
                widget.actionButtons.intersperse(SizedBox(width: 16)).toList(),
          ),
          if (widget.includeSectors) ...[
            SizedBox(height: 6),
            Padding(
                padding: EdgeInsets.only(left: 0, right: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    sectorIcon(appContext: AppContext.wallet),
                    sectorIcon(appContext: AppContext.manage),
                    sectorIcon(appContext: AppContext.swap),
                  ],
                ))
          ]
        ],
      ),
    );
  }

  Widget sectorIcon({required AppContext appContext}) => Container(
      height: 56,
      width: (MediaQuery.of(context).size.width - 32 - 0) / 3,
      alignment: Alignment.center,
      child: IconButton(
        onPressed: () {
          streams.app.context.add(appContext);
          if (!['Home', 'Manage', 'Swap'].contains(streams.app.page.value)) {
            Navigator.popUntil(components.navigator.routeContext!,
                ModalRoute.withName('/home'));
          }
        },
        icon: Icon({
          AppContext.wallet: MdiIcons.wallet,
          AppContext.manage: MdiIcons.plusCircle,
          AppContext.swap: MdiIcons.swapHorizontalBold,
        }[appContext]!),
        iconSize: streams.app.context.value == appContext ? 32 : 24,
        color: streams.app.context.value == appContext
            ? AppColors.primary
            : Color(0x995C6BC0),
      ));
}
