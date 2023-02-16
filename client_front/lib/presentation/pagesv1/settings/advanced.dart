import 'package:flutter/material.dart';
import 'package:client_front/presentation/widgets/widgets.dart';
import 'package:client_back/client_back.dart';

class AdvancedDeveloperOptions extends StatelessWidget {
  const AdvancedDeveloperOptions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackdropLayers(
        back: const BlankBack(),
        front: FrontCurve(
            child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: CustomScrollView(slivers: <Widget>[
            SliverToBoxAdapter(
                child: Padding(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 16, bottom: 16),
                    child: Container(
                        alignment: Alignment.topLeft,
                        child: SwtichChoice(
                            label: 'Advanced Developer Mode',
                            description:
                                'Unlocks experimental functionality. Use at your own risk. Make a paper backup of all wallets first.',
                            initial: services.developer.advancedDeveloperMode,
                            onChanged: (bool value) async {
                              await services.developer.toggleAdvDevMode(value);
                              await services.developer.postToggleFeatureCheck();
                              final ChainNet? chainNet = services.developer
                                  .postToggleBlockchainCheck();
                              if (chainNet != null) {
                                changeChainNet(context, chainNet);
                              }
                            })))),
          ]),
        )));
  }
}
