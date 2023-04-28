import 'package:flutter/material.dart';
import 'package:client_front/presentation/widgets/other/page.dart';
import 'package:client_front/presentation/widgets/front/choices/blockchain_choice.dart';

class BlockchainSettings extends StatelessWidget {
  const BlockchainSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageStructure(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[const BlockchainChoice()],
    );
  }
}
