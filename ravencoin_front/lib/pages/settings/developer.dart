import 'package:flutter/material.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:tuple/tuple.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_front/widgets/widgets.dart';
import 'package:ravencoin_front/components/components.dart';

class DeveloperOptions extends StatelessWidget {
  const DeveloperOptions() : super();

  @override
  Widget build(BuildContext context) {
    return BackdropLayers(
        back: BlankBack(),
        front: FrontCurve(
            child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: CustomScrollView(slivers: <Widget>[
            SliverToBoxAdapter(
                child: Padding(
                    padding: EdgeInsets.only(
                        left: 16, right: 16, top: 16, bottom: 16),
                    child: Container(
                        alignment: Alignment.topLeft,
                        child: SwtichChoice(
                            label: 'Developer Mode',
                            initial: services.developer.developerMode,
                            onChanged: (value) async {
                              await services.developer.toggleDevMode(value);
                              if (!services.developer
                                  .postToggleBlockchainCheck()) {
                                if (pros.settings.net == Net.test &&
                                    services
                                        .developer
                                        .featureLevelBlockchainMap[
                                            services.developer.userLevel]!
                                        .contains(Tuple2(
                                            pros.settings.chain, Net.main))) {
                                  changeChainNet(context,
                                      Tuple2(pros.settings.chain, Net.main));
                                } else {
                                  changeChainNet(context,
                                      Tuple2(Chain.ravencoin, Net.main));
                                }
                              }
                            })))),
          ]),
        )));
  }

  void changeChainNet(
    BuildContext context,
    Tuple2<Chain, Net> value, {
    Function(Tuple2<Chain, Net>)? first,
    Function? second,
  }) async {
    Navigator.of(context).pop();
    streams.client.busy.add(true);
    (first ?? (_) {})(value);
    components.loading.screen(
      message:
          'Connecting to ${value.item1.name.toTitleCase()}${value.item2 == Net.test ? ' ' + value.item2.name.toTitleCase() : ''}',
      returnHome: false,
      playCount: 5,
    );
    await services.client.switchNetworks(chain: value.item1, net: value.item2);
    streams.app.snack.add(Snack(message: 'Successfully connected'));
    (second ?? () {})();
  }
}
