import 'package:intersperse/intersperse.dart';
import 'package:flutter/material.dart';

class PageComponents {
  /// front page widget made mainly for forms
  Widget form(
    BuildContext context, {
    List<Widget>? boxedWidgets,
    List<Widget>? columnWidgets,
    List<Widget>? buttons,
    List<Widget>? layeredWidgets,
    Widget? heightSpacer,
    Widget? widthSpacer,
  }) {
    heightSpacer = heightSpacer ?? SizedBox(height: 16);
    widthSpacer = widthSpacer ?? SizedBox(width: 16);
    return Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 0),
        child: CustomScrollView(slivers: <Widget>[
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
          SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          for (var widget in buttons ?? []) widget
                        ]),
                    SizedBox(height: 40),
                  ])),
        ]));
  }
}
