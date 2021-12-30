import 'package:flutter/material.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:raven_front/widgets/connection.dart';

class HeaderComponents {
  PreferredSize simple(BuildContext context, String title) => PreferredSize(
      preferredSize: Size.fromHeight(56),
      child: SafeArea(
          child: Stack(children: [
        shadows,
        AppBar(
            centerTitle: false,
            title: Text(title, style: Theme.of(context).pageName),
            actions: <Widget>[components.status])
      ])));

  PreferredSize back(
    BuildContext context,
    String title, {
    List<Widget>? extraActions,
  }) =>
      PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: SafeArea(
              child: Stack(children: [
            shadows,
            AppBar(
              leading: components.buttons.back(context),
              centerTitle: false,
              title: Text(title, style: Theme.of(context).pageName),
              actions: <Widget>[
                ...[for (var action in extraActions ?? []) action],
                components.status,
                //ConnectionLight(),
                SizedBox(width: 16),
                Icon(Icons.qr_code_scanner_rounded, size: 24),
                SizedBox(width: 16)
              ],
            )
          ])));

  PreferredSize asset(BuildContext context, String title,
          {required String balance}) =>
      PreferredSize(
          preferredSize: Size.fromHeight(256),
          child: SafeArea(
              child: Stack(children: [
            shadows,
            AppBar(
                primary: true,
                automaticallyImplyLeading: true,
                centerTitle: false,
                actions: <Widget>[
                  components.status,
                  //ConnectionLight(),
                  SizedBox(width: 16),
                  Icon(Icons.qr_code_scanner_rounded, size: 24),
                  SizedBox(width: 16)
                ],
                title: Text(title, style: Theme.of(context).pageName),
                flexibleSpace: Container(
                    alignment: Alignment.center,
                    // balance view should listen for valid usd
                    // show spinnter until valid usd rate appears, then rvnUSD
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(balance, style: Theme.of(context).pageValue),
                        ])))
          ])));

  Container get shadows => Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(8.0),
                  bottomLeft: Radius.circular(8.0)),
              color: const Color(0xffffffff),
              boxShadow: [
            BoxShadow(
                color: const Color(0x33000000),
                offset: Offset(0, 2),
                blurRadius: 4),
            BoxShadow(
                color: const Color(0x1F000000),
                offset: Offset(0, 1),
                blurRadius: 10),
            BoxShadow(
                color: const Color(0x24000000),
                offset: Offset(0, 4),
                blurRadius: 5),
          ]));
}
