import 'package:flutter/material.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/presentation/theme/colors.dart';
import 'package:magic/presentation/utils/animation.dart';
import 'package:magic/services/services.dart';

enum BackupLifeCycle {
  entering,
  hidden,
  shown,
  exiting;

  String get msg {
    switch (this) {
      case BackupLifeCycle.entering:
        return 'Are you sure you want to reveal sensitive wallet data on screen?';
      case BackupLifeCycle.hidden:
        return 'Are you sure you want to reveal sensitive wallet data on screen?';
      case BackupLifeCycle.exiting:
        return ' ';
      default:
        return '';
    }
  }

  String get submitText {
    switch (this) {
      case BackupLifeCycle.shown:
        return 'DONE';
      default:
        return 'REVEAL';
    }
  }

  bool get animating => [
        BackupLifeCycle.entering,
        BackupLifeCycle.exiting,
      ].contains(this);
}

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  BackupPageState createState() => BackupPageState();
}

class BackupPageState extends State<BackupPage> {
  BackupLifeCycle lifecycle = BackupLifeCycle.entering;

  void toStage(BackupLifeCycle stage) {
    if (mounted) {
      if (stage == BackupLifeCycle.exiting) {
        cubits.app.animating = true;
        Future.delayed(slideDuration * 1.1, () {
          cubits.welcome.update(active: false, child: const SizedBox.shrink());
          cubits.app.animating = true;
        });
      }
      setState(() => lifecycle = stage);
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (lifecycle == BackupLifeCycle.entering) {
        toStage(BackupLifeCycle.hidden);
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
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                color: Colors.white),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: Colors.black54),
                        onPressed: () => toStage(BackupLifeCycle.exiting))),
                if (lifecycle.msg != '')
                  Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        lifecycle.msg,
                        textAlign: TextAlign.center,
                      ))
                else
                  Column(children: [
                    const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'To backup your wallet, write these words down on paper and store them in a safe place.',
                          textAlign: TextAlign.center,
                        )),
                    ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: screen.height - 60 - 60 - 32 - 100,
                        ),
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount:
                                cubits.keys.master.mnemonicWallets.length +
                                    cubits.keys.master.keypairWallets.length,
                            itemBuilder: (context, int index) => Container(
                                padding:
                                    const EdgeInsets.only(top: 16, bottom: 16),
                                decoration: index <
                                        cubits.keys.master.mnemonicWallets
                                                .length +
                                            cubits.keys.master.keypairWallets
                                                .length -
                                            1
                                    ? const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors
                                                .black54, // Set the color of the border
                                            width:
                                                2.0, // Set the width of the border
                                          ),
                                        ),
                                      )
                                    : null,
                                child: index <
                                        cubits
                                            .keys.master.mnemonicWallets.length
                                    ? Wrap(children: <Widget>[
                                        for (final word in cubits.keys.master
                                            .mnemonicWallets[0].words)
                                          Container(
                                              padding: const EdgeInsets.only(
                                                  left: 8,
                                                  right: 8,
                                                  top: 4,
                                                  bottom: 4),
                                              child: Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8,
                                                          right: 8,
                                                          top: 4,
                                                          bottom: 4),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: AppColors
                                                            .primary100),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                  child: Text(word))),
                                      ])
                                    : Container(
                                        padding: const EdgeInsets.only(
                                            left: 8,
                                            right: 8,
                                            top: 4,
                                            bottom: 4),
                                        child: Container(
                                            padding: const EdgeInsets.only(
                                                left: 8,
                                                right: 8,
                                                top: 4,
                                                bottom: 4),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: AppColors.primary100),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Text(
                                                'wif: ${cubits.keys.master.keypairWallets[index].wif}')))))),
                  ]),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onHover: (_) => cubits.app.animating = true,
                      onPressed: () {
                        if (lifecycle == BackupLifeCycle.hidden) {
                          toStage(BackupLifeCycle.shown);
                        } else if (lifecycle == BackupLifeCycle.shown) {
                          toStage(BackupLifeCycle.exiting);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        lifecycle.submitText,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
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
