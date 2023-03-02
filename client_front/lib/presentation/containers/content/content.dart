import 'package:flutter/material.dart';
import 'package:client_front/presentation/containers/content/appbar.dart';
import 'package:client_front/presentation/containers/content/front.dart';
import 'package:client_front/presentation/containers/content/back.dart';
import 'package:client_front/presentation/services/services.dart' as uiservices;

class ContentScaffold extends StatelessWidget {
  final Widget? child;
  const ContentScaffold({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      // SingleChildScrollView used because render error when system bar active
      SingleChildScrollView(
          controller: ScrollController(),
          child: SizedBox(
            height: uiservices.screen.app.height,
            child: Column(children: <Widget>[
              const CustomAppBar(),
              ContentBulk(child: child)
            ]),
          ));
}

class ContentBulk extends StatelessWidget {
  final Widget? child;
  const ContentBulk({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        alignment: Alignment.bottomCenter,
        height: uiservices.screen.frontContainer.maxHeight,
        child: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            const BackContainer(),
            FrontContainer(child: child),
          ],
        ),
      );
}
