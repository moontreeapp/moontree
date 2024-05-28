import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/welcome/cubit.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/domain.dart';
import 'package:magic/presentation/theme/colors.dart';
import 'package:magic/presentation/utils/animation.dart';
import 'package:magic/services/services.dart';

class WelcomeLayer extends StatelessWidget {
  const WelcomeLayer({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<WelcomeCubit, WelcomeState>(
          //buildWhen: (WelcomeState previous, WelcomeState current) =>
          //    current.active || !current.active,
          builder: (BuildContext context, WelcomeState state) {
        if (state.active && state.child != null) {
          return state.child!;
        }
        return const SizedBox.shrink();
      });
}

class WelcomeBackScreen extends StatefulWidget {
  const WelcomeBackScreen({super.key});

  @override
  WelcomeBackScreenState createState() => WelcomeBackScreenState();
}

class WelcomeBackScreenState extends State<WelcomeBackScreen> {
  bool _isAnimating = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedPositioned(
          duration: slowFadeDuration,
          curve: Curves.easeInCubic,
          top: _isAnimating ? MediaQuery.of(context).size.height : 0,
          left: 0,
          right: 0,
          child: AnimatedContainer(
            duration: slowFadeDuration,
            curve: Curves.easeOutCubic,
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(_isAnimating ? 30 : 0)),
                color: Colors.white),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'Magic',
                          style: TextStyle(
                            fontSize: 40,
                            fontFamily: 'Pacifico',
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onHover: (_) => cubits.app.animating = true,
                      onPressed: () {
                        cubits.app.animating = true;
                        setState(() {
                          _isAnimating = true;
                        });
                        Future.delayed(slowFadeDuration, () {
                          cubits.welcome.update(
                              active: false, child: const SizedBox.shrink());
                          cubits.app.animating = false;
                          //deriveInBackground();
                          cubits.receive
                              .populateAddresses(Blockchain.ravencoinMain);
                          cubits.receive
                              .populateAddresses(Blockchain.evrmoreMain);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "LET'S GO",
                        style: TextStyle(
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

enum BackupLifeCycle {
  entering,
  hidden,
  shown,
  exiting,
}

class Backup extends StatefulWidget {
  const Backup({super.key});

  @override
  BackupState createState() => BackupState();
}

class BackupState extends State<Backup> {
  BackupLifeCycle lifecycle = BackupLifeCycle.entering;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (lifecycle == BackupLifeCycle.entering) {
        setState(() {
          lifecycle = BackupLifeCycle.hidden;
        });
      }
    });
    return Stack(
      children: <Widget>[
        AnimatedPositioned(
          duration: slowFadeDuration,
          curve: Curves.easeOutCubic,
          top: lifecycle == BackupLifeCycle.entering
              ? screen.height
              : ([BackupLifeCycle.hidden, BackupLifeCycle.shown]
                      .contains(lifecycle)
                  ? 0
                  : screen.height),
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
                        onPressed: () {
                          setState(() {
                            lifecycle = BackupLifeCycle.exiting;
                          });
                          Future.delayed(slowSlideDuration, () {
                            cubits.welcome.update(
                                active: false, child: const SizedBox.shrink());
                          });
                        })),
                if (lifecycle == BackupLifeCycle.entering ||
                    lifecycle == BackupLifeCycle.hidden)
                  const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Are you sure you want to reveal sensitive wallet data on screen?',
                        textAlign: TextAlign.center,
                      )),
                if (lifecycle == BackupLifeCycle.shown ||
                    lifecycle == BackupLifeCycle.exiting) ...[
                  ListView.builder(
                      shrinkWrap: true,
                      itemCount: cubits.keys.master.mnemonicWallets.length,
                      itemBuilder: (context, int index) => Container(
                          padding: const EdgeInsets.only(top: 16, bottom: 16),
                          decoration: index <
                                  cubits.keys.master.mnemonicWallets.length - 1
                              ? const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors
                                          .black54, // Set the color of the border
                                      width: 2.0, // Set the width of the border
                                    ),
                                  ),
                                )
                              : null,
                          child: Wrap(children: <Widget>[
                            for (final word
                                in cubits.keys.master.mnemonicWallets[0].words)
                              Container(
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
                                      child: Text(word))),
                          ]))),
                  if (cubits.keys.master.keypairWallets.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: cubits.keys.master.keypairWallets.length,
                      itemBuilder: (context, int index) => Container(
                          padding: const EdgeInsets.only(top: 16, bottom: 16),
                          decoration: index <
                                  cubits.keys.master.mnemonicWallets.length - 1
                              ? const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors
                                          .black54, // Set the color of the border
                                      width: 2.0, // Set the width of the border
                                    ),
                                  ),
                                )
                              : null,
                          child: Text(
                              'wif: ${cubits.keys.master.keypairWallets[index].wif}')),
                    ),
                ],
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onHover: (_) => cubits.app.animating = true,
                      onPressed: () {
                        if (lifecycle == BackupLifeCycle.hidden) {
                          setState(() {
                            lifecycle = BackupLifeCycle.shown;
                          });
                        } else if (lifecycle == BackupLifeCycle.shown) {
                          cubits.app.animating = true;
                          setState(() {
                            lifecycle = BackupLifeCycle.exiting;
                          });
                          Future.delayed(slowFadeDuration, () {
                            cubits.welcome.update(
                                active: false, child: const SizedBox.shrink());
                            cubits.app.animating = false;
                            //deriveInBackground();
                            cubits.receive
                                .populateAddresses(Blockchain.ravencoinMain);
                            cubits.receive
                                .populateAddresses(Blockchain.evrmoreMain);
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        lifecycle == BackupLifeCycle.shown ? 'DONE' : 'REVEAL',
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
