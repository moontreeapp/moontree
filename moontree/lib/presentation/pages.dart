import 'package:flutter/material.dart';
import 'package:moontree/presentation/ui/home/home.dart';
import 'package:moontree/services/services.dart' as services;

class PagesLayer extends StatelessWidget {
  const PagesLayer({super.key});

  @override
  Widget build(BuildContext context) =>
      // SingleChildScrollView used because render error when system bar active
      SingleChildScrollView(
          controller: ScrollController(),
          child: SizedBox(
            height: services.screen.app.height,
            child: const ContentBulk(),
          ));
}

class ContentBulk extends StatelessWidget {
  const ContentBulk({super.key});

  @override
  Widget build(BuildContext context) => Container(
        alignment: Alignment.topCenter,
        height: services.screen.frontContainer.maxHeight,
        child: const Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            WalletLayer(),
          ],
        ),
      );
}
