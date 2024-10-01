import 'package:flutter/material.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/presentation/theme/colors.dart';
import 'package:magic/presentation/utils/animation.dart';
import 'package:magic/services/services.dart';

enum WalletsLifecycle {
  entering,
  shown,
  exiting;

  bool get animating => [
        WalletsLifecycle.entering,
        WalletsLifecycle.exiting,
      ].contains(this);
}

class WalletsPage extends StatefulWidget {
  const WalletsPage({super.key});

  @override
  WalletsPageState createState() => WalletsPageState();
}

class WalletsPageState extends State<WalletsPage> {
  WalletsLifecycle lifecycle = WalletsLifecycle.entering;

  void toStage(WalletsLifecycle stage) {
    if (mounted) {
      if (stage == WalletsLifecycle.exiting) {
        cubits.app.animating = true;
        Future.delayed(slideDuration * 1.1, () {
          cubits.welcome.update(active: false, child: const SizedBox.shrink());
          cubits.app.animating = false;
        });
      }
      setState(() => lifecycle = stage);
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (lifecycle == WalletsLifecycle.entering) {
        toStage(WalletsLifecycle.shown);
      }
    });
    return Stack(
      children: <Widget>[
        AnimatedPositioned(
          duration: slideDuration,
          curve: Curves.easeOutCubic,
          top: lifecycle.animating ? screen.height : 0,
          left: 0,
          right: 0,
          child: Container(
            alignment: Alignment.center,
            height: screen.height,
            padding: const EdgeInsets.only(left: 16),
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                color: AppColors.foreground),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: Colors.white54),
                        onPressed: () => toStage(WalletsLifecycle.exiting))),
                Column(children: [
                  const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Your Wallets',
                        textAlign: TextAlign.center,
                      )),
                  ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: screen.height - 60 - 60 - 32 - 100,
                      ),
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount:
                              cubits.keys.master.derivationWallets.length +
                                  cubits.keys.master.keypairWallets.length,
                          itemBuilder: (context, int index) =>
                              //Container(
                              //    padding:
                              //        const EdgeInsets.only(top: 16, bottom: 16),
                              //    decoration: index <
                              //            cubits.keys.master.derivationWallets
                              //                    .length +
                              //                cubits.keys.master.keypairWallets
                              //                    .length -
                              //                1
                              //        ? const BoxDecoration(
                              //            border: Border(
                              //              bottom: BorderSide(
                              //                color: Colors
                              //                    .black38, // Set the color of the border
                              //                width:
                              //                    1.0, // Set the width of the border
                              //              ),
                              //            ),
                              //          )
                              //        : null,
                              //    child:
                              index <
                                      cubits
                                          .keys.master.derivationWallets.length
                                  ? ListTile(
                                      dense: true,
                                      visualDensity: VisualDensity.compact,
                                      iconColor: Colors.white70,
                                      textColor: Colors.white70,
                                      title: Text(
                                        'Wallet $index (HD wallet)',
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete_rounded),
                                        onPressed: () async {
                                          await cubits.keys.removeMnemonic(
                                              cubits
                                                  .keys
                                                  .master
                                                  .derivationWallets[index]
                                                  .mnemonic!);
                                          await cubits.keys.saveSecrets();

                                          ///// do we need to resetup our subscriptions? yes.
                                          ///// all of them or just this wallet? just do all of them.
                                          //await subscription.setupSubscriptions(
                                          //    cubits.keys.master);

                                          /// do we need to get all our assets again? yes.
                                          /// all of them or just this wallet? just do all of them.
                                          //cubits.wallet.clearAssets();
                                          await cubits.wallet.populateAssets();

                                          /// do we need to derive all our addresses? yes.
                                          /// all of them or just this wallet? we can specify just this wallet.
                                          deriveInBackground();
                                          // why not use this like we do on startup...?
                                          //cubits.receive.deriveAll([
                                          //  Blockchain.ravencoinMain,
                                          //  Blockchain.evrmoreMain,
                                          //]);

                                          setState(() {});
                                        },
                                      ),
                                    )
                                  : ListTile(
                                      dense: true,
                                      visualDensity: VisualDensity.compact,
                                      title: Text(
                                          'Wallet $index (Keypair wallet)'),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete_rounded),
                                        onPressed: () async {
                                          final kpIndex = index -
                                              cubits.keys.master
                                                  .derivationWallets.length;
                                          await cubits.keys.removeWif(cubits
                                              .keys
                                              .master
                                              .keypairWallets[kpIndex]
                                              .wif);
                                          await cubits.keys.saveSecrets();

                                          /// do we need to resetup our subscriptions? yes.
                                          /// all of them or just this wallet? just do all of them.
                                          await subscription.setupSubscriptions(
                                              cubits.keys.master);

                                          /// do we need to get all our assets again? yes.
                                          /// all of them or just this wallet? just do all of them.
                                          //cubits.wallet.clearAssets();
                                          await cubits.wallet.populateAssets();

                                          /// do we need to derive all our addresses? yes.
                                          /// all of them or just this wallet? we can specify just this wallet.
                                          deriveInBackground();
                                          // why not use this like we do on startup...?
                                          //cubits.receive.deriveAll([
                                          //  Blockchain.ravencoinMain,
                                          //  Blockchain.evrmoreMain,
                                          //]);

                                          setState(() {});
                                        },
                                      ),
                                    )))
                  //)
                  ,
                ]),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () => toStage(WalletsLifecycle.exiting),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'CLOSE',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
