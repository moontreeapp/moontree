import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/application/layers/tutorial/cubit.dart';
import 'package:client_front/presentation/theme/theme.dart';
import 'package:client_front/presentation/pages/appbar/connection.dart';
import 'package:client_front/presentation/widgets/other/speech_bubble.dart';
import 'package:client_front/presentation/widgets/other/other.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;

class TutorialLayer extends StatelessWidget {
  const TutorialLayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TutorialCubit, TutorialCubitState>(
        builder: (BuildContext context, TutorialCubitState state) {
      if (state.showTutorials.length > 0) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 1000),
          height: null,
          color: AppColors.scrim,
          child: GestureDetector(
            onTap: () =>
                components.cubits.tutorial.viewed(state.showTutorials.first),
            behavior: HitTestBehavior.opaque,
            child: state.showTutorials.first == TutorialStatus.blockchain
                ? TutorialBlockchain()
                : state.showTutorials.first == TutorialStatus.wallet
                    ? TutorialWallet()
                    : Container(),
          ),
        );
      }
      return SizedBox.shrink();
    });
  }
}

class TutorialBlockchain extends StatelessWidget {
  const TutorialBlockchain({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => IgnorePointer(
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  actions: <Widget>[
                    const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: ConnectionLight()),
                    const SizedBox(width: 16),
                  ])),
          body: Container(
            alignment: Alignment.topRight,
            padding: const EdgeInsets.only(top: 1, right: 3),
            child: SpeechBubble(
              nipOffCenter: 86,
              child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Text('Tap to switch Blockchains',
                    style: Theme.of(context).textTheme.bodyLarge),
              ]),
            ),
          )));
}

class TutorialWallet extends StatelessWidget {
  const TutorialWallet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => IgnorePointer(
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: SizedBox(width: 40),
                  title: Column(children: [
                    SizedBox(height: 4),
                    Text('Wallet 1',
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium!
                            .copyWith(color: AppColors.white))
                  ]),
                  actions: <Widget>[])),
          body: Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(top: 1, left: 80),
            child: SpeechBubble(
              nipOffCenter: -70,
              child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Text('Tap to switch Wallets',
                    style: Theme.of(context).textTheme.bodyLarge),
              ]),
            ),
          )));
}
