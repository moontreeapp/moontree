import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/welcome/cubit.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/presentation/utils/animation.dart';

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
