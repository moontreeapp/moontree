/// see Send, this used to be the only real way to make a form that behaved
/// our custom way we wanted, but now with the new backdrop it was replaced
/// in send by an inverted BackdropLayers and a Stack ListView on the front
/// so this might be obsolete.

import 'package:intersperse/intersperse.dart';
import 'package:flutter/material.dart';

import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/widgets/widgets.dart';

class PageComponents {
  Widget form(
    BuildContext context, {
    List<Widget>? boxedWidgets,
    List<Widget>? columnWidgets,
    List<Widget>? buttons,
    List<Widget>? floatingButtons,
    List<Widget>? layeredButtons,
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
            children: <Widget>[
              fields,
              KeyboardHidesWidgetWithDelay(
                  child: components.buttons.floatingButtons(
                context,
                buttons: floatingButtons,
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
        padding: EdgeInsets.only(left: 0, right: 0, top: 10, bottom: 0),
        alignment: Alignment.bottomCenter,
        child: CustomScrollView(
            //shrinkWrap: true,
            controller: controller,
            physics: NeverScrollableScrollPhysics(),
            slivers: <Widget>[
              SliverToBoxAdapter(child: SizedBox(height: 6)),
              ...<Widget>[
                if ((boxedWidgets ?? []).isNotEmpty)
                  for (var widget in boxedWidgets!)
                    SliverToBoxAdapter(
                        child: Padding(
                            padding: EdgeInsets.only(left: 16, right: 16),
                            child: widget))
              ].intersperse(heightSpacer),
              if ((columnWidgets ?? []).isNotEmpty)
                SliverToBoxAdapter(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (var widget in columnWidgets!)
                      Padding(
                          padding: EdgeInsets.only(left: 16, right: 16),
                          child: widget)
                  ].intersperse(heightSpacer).toList(),
                )),
              if (extraSpace)
                SliverToBoxAdapter(child: SizedBox(height: 120.0)),
              if (buttons != null)
                SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          components.containers.navBar(context,
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    for (var widget in buttons) widget
                                  ].intersperse(widthSpacer).toList())),
                        ])),
            ]));
  }
}
