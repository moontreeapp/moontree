import 'package:intersperse/intersperse.dart';
import 'package:flutter/material.dart';

import 'package:raven_front/components/components.dart';
import 'package:raven_front/widgets/widgets.dart';

class PageComponents {
  Widget form(
    BuildContext context, {
    List<Widget>? boxedWidgets,
    List<Widget>? columnWidgets,
    List<Widget>? buttons,
    List<Widget>? floatingButtons,
    Widget? heightSpacer,
    Widget? widthSpacer,
    ScrollController? controller,
  }) {
    heightSpacer = heightSpacer ?? SizedBox(height: 16);
    widthSpacer = widthSpacer ?? SizedBox(width: 16);
    var fields = formFields(
      context,
      boxedWidgets: boxedWidgets,
      columnWidgets: columnWidgets,
      buttons: buttons,
      heightSpacer: heightSpacer,
      widthSpacer: widthSpacer,
      extraSpace: floatingButtons != null,
      controller: controller,
    );
    return floatingButtons == null
        ? fields
        : Stack(
            children: [
              fields,
              KeyboardHidesWidget(
                  child: components.buttons.floatingButtons(
                context,
                boxedWidgets: boxedWidgets,
                columnWidgets: columnWidgets,
                buttons: floatingButtons,
                heightSpacer: heightSpacer,
                widthSpacer: widthSpacer,
              ))
            ],
          );
  }

  Widget formFields(
    BuildContext context, {
    List<Widget>? boxedWidgets,
    List<Widget>? columnWidgets,
    List<Widget>? buttons,
    Widget? heightSpacer,
    Widget? widthSpacer,
    ScrollController? controller,
    bool extraSpace = false,
  }) {
    heightSpacer = heightSpacer ?? SizedBox(height: 16);
    widthSpacer = widthSpacer ?? SizedBox(width: 16);
    return Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 0),
        child: CustomScrollView(controller: controller, slivers: <Widget>[
          SliverToBoxAdapter(child: SizedBox(height: 6)),
          ...<Widget>[
            if ((boxedWidgets ?? []).isNotEmpty)
              for (var widget in boxedWidgets!)
                SliverToBoxAdapter(child: widget)
          ].intersperse(heightSpacer),
          if ((columnWidgets ?? []).isNotEmpty)
            SliverToBoxAdapter(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[for (var widget in columnWidgets!) widget]
                  .intersperse(heightSpacer)
                  .toList(),
            )),
          if (extraSpace) SliverToBoxAdapter(child: SizedBox(height: 120.0)),
          if (buttons != null)
            SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            for (var widget in buttons) widget
                          ]),
                      SizedBox(height: 40),
                    ])),
        ]));
  }
}
