import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/toast/cubit.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/blockchain/exposure.dart';
import 'package:magic/domain/wallet/wallets.dart';
import 'package:magic/presentation/theme/colors.dart';
import 'package:magic/presentation/utils/animation.dart';
import 'package:magic/presentation/utils/range.dart';
import 'package:magic/services/services.dart';
import 'package:magic/utils/log.dart';

enum AddressesLifeCycle {
  entering,
  shown,
  exiting;

  String get msg {
    switch (this) {
      case AddressesLifeCycle.entering:
        return 'Are you sure you want to reveal sensitive wallet data on screen?';
      case AddressesLifeCycle.exiting:
        return ' ';
      default:
        return '';
    }
  }

  String get submitText {
    switch (this) {
      default:
        return 'CLOSE';
    }
  }

  bool get animating => [
        AddressesLifeCycle.entering,
        AddressesLifeCycle.exiting,
      ].contains(this);
}

class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});

  @override
  AddressesPageState createState() => AddressesPageState();
}

class AddressesPageState extends State<AddressesPage> {
  AddressesLifeCycle lifecycle = AddressesLifeCycle.entering;

  void toStage(AddressesLifeCycle stage) {
    if (mounted) {
      if (stage == AddressesLifeCycle.exiting) {
        cubits.app.animating = true;
        Future.delayed(slideDuration * 1.1, () {
          cubits.welcome.update(active: false, child: const SizedBox.shrink());
          cubits.app.animating = false;
        });
      }
      setState(() => lifecycle = stage);
    }
  }

  void copyToClipboard(String address) {
    Clipboard.setData(ClipboardData(text: address));
    cubits.toast.flash(
      msg: const ToastMessage(
        duration: Duration(seconds: 2),
        title: 'Copied',
        text: 'Address copied to clipboard',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (lifecycle == AddressesLifeCycle.entering) {
        toStage(AddressesLifeCycle.shown);
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
            padding: const EdgeInsets.only(top: 8, left: 16),
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                color: AppColors.background),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: Colors.white54),
                        onPressed: () => toStage(AddressesLifeCycle.exiting))),
                Column(children: [
                  ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: screen.height - 60 - 60 - 32 - 100,
                      ),
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount:
                              cubits.keys.master.derivationWallets.length,
                          itemBuilder: (context, int index) {
                            for (int index = 0;
                                index <
                                    cubits.keys.master.derivationWallets.length;
                                index++) {
                              see('Wallet Index: $index');
                              for (final blockchain in Blockchain.mainnets) {
                                for (final exposure in Exposure.values) {
                                  see('Exposure: ${exposureLabel(exposure)}');
                                  if (cubits.keys.master
                                      .derivationWallets[index].hot) {
                                    for (final subwallet in cubits
                                        .keys.master.derivationWallets[index]
                                        .seedWallet(blockchain)
                                        .subwallets[exposure]!) {
                                      see('Wallet: $index (${exposureLabel(exposure)}: ${(subwallet is HDWalletIndexed) ? subwallet.hdIndex : -1})\n${subwallet.address ?? 'unknown'}');
                                      Container(
                                          padding: const EdgeInsets.only(
                                              left: 8,
                                              right: 8,
                                              top: 4,
                                              bottom: 4),
                                          child: Row(
                                            children: [
                                              ColorFiltered(
                                                colorFilter: const ColorFilter
                                                    .matrix(<double>[
                                                  0.2126,
                                                  0.7152,
                                                  0.0722,
                                                  0,
                                                  0,
                                                  0.2126,
                                                  0.7152,
                                                  0.0722,
                                                  0,
                                                  0,
                                                  0.2126,
                                                  0.7152,
                                                  0.0722,
                                                  0,
                                                  0,
                                                  0,
                                                  0,
                                                  0,
                                                  1,
                                                  0,
                                                ]),
                                                child: Image.asset(
                                                    blockchain.logo,
                                                    width: 40,
                                                    height: 40),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                    'Wallet: $index (${exposureLabel(exposure)}: ${(subwallet is HDWalletIndexed) ? subwallet.hdIndex : -1})\n${subwallet.address ?? 'unknown'}'),
                                              ),
                                            ],
                                          ));
                                    }
                                  } else {
                                    final maxId = cubits
                                            .keys
                                            .master
                                            .derivationWallets[index]
                                            .maxIds[blockchain]?[exposure] ??
                                        0;
                                    print(maxId);
                                    for (final idx in range(maxId + 1)) {
                                      final xpub = cubits
                                          .keys.master.derivationWallets[index]
                                          .rootsMap(blockchain)[exposure]!;
                                      see('Wallet: $index (${exposureLabel(exposure)}: $idx)\n${blockchain.addressFromXPub(xpub, idx)}');
                                      Container(
                                          padding: const EdgeInsets.only(
                                              left: 8,
                                              right: 8,
                                              top: 4,
                                              bottom: 4),
                                          child: Row(
                                            children: [
                                              ColorFiltered(
                                                colorFilter: const ColorFilter
                                                    .matrix(<double>[
                                                  0.2126,
                                                  0.7152,
                                                  0.0722,
                                                  0,
                                                  0,
                                                  0.2126,
                                                  0.7152,
                                                  0.0722,
                                                  0,
                                                  0,
                                                  0.2126,
                                                  0.7152,
                                                  0.0722,
                                                  0,
                                                  0,
                                                  0,
                                                  0,
                                                  0,
                                                  1,
                                                  0,
                                                ]),
                                                child: Image.asset(
                                                    blockchain.logo,
                                                    width: 40,
                                                    height: 40),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                    'Wallet: $index (${exposureLabel(exposure)}: $idx)\n${blockchain.addressFromXPub(cubits.keys.master.derivationWallets[index].rootsMap(blockchain)[exposure]!, idx)}'),
                                              ),
                                            ],
                                          ));
                                    }
                                  }
                                }
                              }
                            }
                            return Container(
                                padding:
                                    const EdgeInsets.only(top: 16, bottom: 16),
                                decoration: index <
                                        cubits.keys.master.derivationWallets
                                                .length -
                                            1
                                    ? const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors
                                                .white38, // Set the color of the border
                                            width:
                                                1.0, // Set the width of the border
                                          ),
                                        ),
                                      )
                                    : null,
                                child: Wrap(children: <Widget>[
                                  for (final blockchain in Blockchain.mainnets)
                                    for (final exposure in Exposure.values)
                                      if (cubits.keys.master
                                          .derivationWallets[index].hot)
                                        for (final subwallet in cubits.keys
                                            .master.derivationWallets[index]
                                            .seedWallet(blockchain)
                                            .subwallets[exposure]!)
                                          Container(
                                              padding: const EdgeInsets.only(
                                                  left: 8,
                                                  right: 8,
                                                  top: 4,
                                                  bottom: 4),
                                              child: Row(
                                                children: [
                                                  ColorFiltered(
                                                    colorFilter:
                                                        const ColorFilter
                                                            .matrix(<double>[
                                                      0.2126,
                                                      0.7152,
                                                      0.0722,
                                                      0,
                                                      0,
                                                      0.2126,
                                                      0.7152,
                                                      0.0722,
                                                      0,
                                                      0,
                                                      0.2126,
                                                      0.7152,
                                                      0.0722,
                                                      0,
                                                      0,
                                                      0,
                                                      0,
                                                      0,
                                                      1,
                                                      0,
                                                    ]),
                                                    child: Image.asset(
                                                        blockchain.logo,
                                                        width: 40,
                                                        height: 40),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Text(
                                                        'Wallet: $index (${exposureLabel(exposure)}: ${(subwallet is HDWalletIndexed) ? subwallet.hdIndex : -1})\n${subwallet.address ?? 'unknown'}'),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.copy,
                                                      color: Colors.white70,
                                                    ),
                                                    onPressed: () =>
                                                        copyToClipboard(
                                                            subwallet.address ??
                                                                'unknown'),
                                                  ),
                                                ],
                                              ))
                                      else
                                        for (final idx in range(
                                            (cubits
                                                            .keys
                                                            .master
                                                            .derivationWallets[
                                                                index]
                                                            .maxIds[blockchain]
                                                        ?[exposure] ??
                                                    0) +
                                                1))
                                          Container(
                                              padding: const EdgeInsets.only(
                                                  left: 8,
                                                  right: 8,
                                                  top: 4,
                                                  bottom: 4),
                                              child: Row(
                                                children: [
                                                  ColorFiltered(
                                                    colorFilter:
                                                        const ColorFilter
                                                            .matrix(<double>[
                                                      0.2126,
                                                      0.7152,
                                                      0.0722,
                                                      0,
                                                      0,
                                                      0.2126,
                                                      0.7152,
                                                      0.0722,
                                                      0,
                                                      0,
                                                      0.2126,
                                                      0.7152,
                                                      0.0722,
                                                      0,
                                                      0,
                                                      0,
                                                      0,
                                                      0,
                                                      1,
                                                      0,
                                                    ]),
                                                    child: Image.asset(
                                                        blockchain.logo,
                                                        width: 40,
                                                        height: 40),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Text(
                                                        'Wallet: $index (${exposureLabel(exposure)}: $idx)\n${blockchain.addressFromXPub(cubits.keys.master.derivationWallets[index].rootsMap(blockchain)[exposure]!, idx)}'),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.copy,
                                                      color: Colors.white70,
                                                    ),
                                                    onPressed: () => copyToClipboard(
                                                        blockchain.addressFromXPub(
                                                            cubits
                                                                    .keys
                                                                    .master
                                                                    .derivationWallets[
                                                                        index]
                                                                    .rootsMap(
                                                                        blockchain)[
                                                                exposure]!,
                                                            idx)),
                                                  ),
                                                ],
                                              )),
                                ]));
                          })),
                  ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: screen.height - 60 - 60 - 32 - 100,
                      ),
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: cubits.keys.master.keypairWallets.length,
                          itemBuilder: (context, int index) => Container(
                              padding:
                                  const EdgeInsets.only(top: 16, bottom: 16),
                              decoration: index <
                                      cubits.keys.master.keypairWallets.length -
                                          1
                                  ? const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors
                                              .white38, // Set the color of the border
                                          width:
                                              1.0, // Set the width of the border
                                        ),
                                      ),
                                    )
                                  : null,
                              child: Container(
                                  padding: const EdgeInsets.only(
                                      left: 8, right: 8, top: 4, bottom: 4),
                                  child: Container(
                                      padding: const EdgeInsets.only(
                                          left: 8, right: 8, top: 4, bottom: 4),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: AppColors.primary100),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Wrap(children: <Widget>[
                                        for (final blockchain
                                            in Blockchain.values)
                                          Text(cubits
                                              .keys.master.keypairWallets[index]
                                              .address(blockchain))
                                      ])))))),
                ]),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
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

String exposureLabel(Exposure exposure) {
  switch (exposure) {
    case Exposure.internal:
      return 'Change';
    case Exposure.external:
      return 'Receive';
    default:
      return exposure.name;
  }
}
