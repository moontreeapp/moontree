import 'package:flutter/material.dart';
import 'package:raven_mobile/components/components.dart';
import 'package:raven_mobile/indicators/indicators.dart';

class HeaderComponents {
  AppBar simple(String title) => AppBar(
        elevation: 2,
        centerTitle: false,
        title: Text(title),
        actions: [
          components.status,
          indicators.process,
          indicators.client,
        ],
      );

  AppBar back(
    BuildContext context,
    String title, {
    List<Widget>? extraActions,
  }) =>
      AppBar(
        leading: components.buttons.back(context),
        elevation: 2,
        centerTitle: false,
        title: Text(title),
        actions: [
          components.status,
          indicators.process,
          indicators.client,
          ...[for (var action in extraActions ?? []) action],
        ],
      );
}
