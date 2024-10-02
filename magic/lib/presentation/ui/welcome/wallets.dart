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
          top: 0,
          bottom: 0,
          left: lifecycle.animating ? screen.width : 0,
          right: lifecycle.animating ? -screen.width : 0,
          child: Container(
            alignment: Alignment.center,
            height: screen.height,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                color: AppColors.background), // Updated background color
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(top: 8, left: 16),
                    child: IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: Colors.white54),
                        onPressed: () => toStage(WalletsLifecycle.exiting))),
                Column(children: [
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
                                      leading: const CircleAvatar(
                                        backgroundColor: AppColors.foreground,
                                        child: Icon(Icons.wallet_rounded,
                                            color: Colors.white38),
                                      ),
                                      title: Text(
                                        'Wallet $index (HD wallet)',
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete_rounded,
                                            color: AppColors.white24),
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
                                      leading: const CircleAvatar(
                                        backgroundColor: AppColors.foreground,
                                        child: Icon(Icons.abc,
                                            color: Colors.white),
                                      ),
                                      title: Text(
                                          'Wallet $index (Keypair wallet)'),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete_rounded,
                                            color: AppColors.white24),
                                        onPressed: () async {
                                          await cubits.keys.removeWif(cubits
                                              .keys
                                              .master
                                              .keypairWallets[index -
                                                  cubits
                                                      .keys
                                                      .master
                                                      .derivationWallets
                                                      .length -
                                                  1]
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
                ]),
                const Padding(
                  padding: EdgeInsets.only(bottom: 32.0, right: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                  ),
                ),
                // const Padding(
                //   padding: EdgeInsets.only(left: 16, right: 16, bottom: 32),
                //   child: SizedBox(
                //     width: double.infinity,
                //     height: 8,
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
