import 'package:flutter/material.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/presentation/widgets/widgets.dart';

class DeveloperOptions extends StatelessWidget {
  const DeveloperOptions({Key? key}) : super(key: key);

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
                            label: 'Developer Mode',
                            initial: services.developer.developerMode,
                            onChanged: (bool value) async {
                              await services.developer.toggleDevMode(value);
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
