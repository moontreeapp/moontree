import 'package:client_front/presentation/widgets/other/buttons.dart';
import 'package:flutter/material.dart';
import 'package:intersperse/intersperse.dart';

class PageStructure extends StatelessWidget {
  final List<Widget> children;
  final List<Widget> firstLowerChildren;
  final List<Widget>? secondLowerChildren;
  final List<Widget>? thirdLowerChildren;
  final Widget? heightSpacer;
  final Widget? widthSpacer;
  const PageStructure({
    super.key,
    required this.children,
    required this.firstLowerChildren,
    this.secondLowerChildren,
    this.thirdLowerChildren,
    this.heightSpacer = const SizedBox(height: 16),
    this.widthSpacer = const SizedBox(width: 16),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        behavior: HitTestBehavior.translucent,
        child: Container(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 40),
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      for (final child in (heightSpacer == null
                          ? children
                          : children.intersperse(heightSpacer!)))
                        child
                    ]),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(children: <Widget>[
                      for (final Widget child in (widthSpacer == null
                          ? firstLowerChildren
                          : firstLowerChildren.intersperse(widthSpacer!)))
                        if (child == widthSpacer)
                          child
                        else
                          Expanded(child: child)
                    ]),
                    if (secondLowerChildren != null)
                      heightSpacer ?? const SizedBox(height: 16),
                    if (secondLowerChildren != null)
                      Row(children: <Widget>[
                        for (final child in (widthSpacer == null
                            ? secondLowerChildren!
                            : secondLowerChildren!.intersperse(widthSpacer!)))
                          if (child == widthSpacer)
                            child
                          else
                            Expanded(child: child)
                      ]),
                    if (thirdLowerChildren != null)
                      heightSpacer ?? const SizedBox(height: 16),
                    if (thirdLowerChildren != null)
                      Row(children: <Widget>[
                        for (final child in (widthSpacer == null
                            ? thirdLowerChildren!
                            : thirdLowerChildren!.intersperse(widthSpacer!)))
                          if (child == widthSpacer)
                            child
                          else
                            Expanded(child: child)
                      ]),
                  ],
                )
              ],
            )));
  }
}
/*
PageStructure(
  children: <Widget>[
  ],
  firstLowerChildren: <Widget>[
  ],
);
*/