import 'package:client_front/presentation/widgets/front/choices/clear_secure_storage.dart';
import 'package:client_front/presentation/widgets/front/choices/resync.dart';
import 'package:flutter/material.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/presentation/widgets/other/page.dart';

class DatabaseSettings extends StatelessWidget {
  const DatabaseSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageStructure(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const ResyncChoice(),
        if (services.developer.advancedDeveloperMode) const ClearSSChoice()
      ],
    );
  }
}
