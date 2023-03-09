import 'package:flutter/material.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/presentation/widgets/other/page.dart';
import 'package:client_front/presentation/widgets/front/choices/blockchain_choice.dart';
import 'package:client_front/presentation/widgets/front/choices/switch_choice.dart';

class DeveloperMode extends StatelessWidget {
  const DeveloperMode({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageStructure(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SwtichChoice(
            label: 'Developer Mode',
            initial: services.developer.developerMode,
            onChanged: (bool value) async {
              await services.developer.toggleDevMode(value);
              await services.developer.postToggleFeatureCheck();
              final ChainNet? chainNet =
                  services.developer.postToggleBlockchainCheck();
              if (chainNet != null) {
                changeChainNet(context, chainNet);
              }
            })
      ],
    );
  }
}
