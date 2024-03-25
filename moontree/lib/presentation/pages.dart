import 'package:flutter/material.dart';
import 'package:moontree/presentation/ui/wallet/wallet.dart';
import 'package:moontree/services/services.dart' as services;

class PagesLayer extends StatelessWidget {
  const PagesLayer({super.key});

  @override
  Widget build(BuildContext context) =>
      // SingleChildScrollView used because render error when system bar active
      //SingleChildScrollView(
      //    controller: ScrollController(),
      //    child:
      Padding(
          padding: EdgeInsets.only(bottom: services.screen.navbar.height),
          child: SizedBox(
            height: services.screen.displayHeight,
            child: const ContentBulk(),
          ))
      //)
      ;
}

class ContentBulk extends StatelessWidget {
  const ContentBulk({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: services.screen.displayHeight,
        child: const Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            //WalletLayer(),
          ],
        ),
      );
}
