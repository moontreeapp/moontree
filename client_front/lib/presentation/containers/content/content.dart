import 'package:flutter/material.dart';
import 'package:client_front/presentation/containers/content/appbar.dart';
import 'package:client_front/presentation/containers/content/front.dart';
import 'package:client_front/presentation/containers/content/back.dart';
import 'package:client_front/presentation/services/services.dart' as uiservices;

class ContentScaffold extends StatelessWidget {
  const ContentScaffold({Key? key}) : super(key: key);

  /// SingleChildScrollView used because of render error when system bar active
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
      controller: ScrollController(),
      child: SizedBox(
        height: uiservices.screen.app.height,
        child: Column(children: const <Widget>[CustomAppBar(), ContentBulk()]),
      ));
}

class ContentBulk extends StatelessWidget {
  const ContentBulk({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        alignment: Alignment.bottomCenter,
        height: uiservices.screen.frontPageContainer.maxHeight,
        child: Stack(
          alignment: Alignment.topCenter,
          children: const <Widget>[
            BackContainer(),
            FrontContainer(),
          ],
        ),
      );
}
