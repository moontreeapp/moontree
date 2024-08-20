import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/welcome/cubit.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/presentation/theme/colors.dart';
import 'package:magic/presentation/utils/animation.dart';
import 'package:magic/presentation/widgets/animations/fading.dart';
import 'package:magic/presentation/widgets/animations/sliding.dart';
import 'package:magic/presentation/widgets/assets/icons.dart';
import 'package:magic/services/services.dart';

class WelcomeLayer extends StatelessWidget {
  const WelcomeLayer({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<WelcomeCubit, WelcomeState>(
          //    //buildWhen: (WelcomeState previous, WelcomeState current) =>
          //    //    current.active || !current.active,
          builder: (BuildContext context, WelcomeState state) {
        if (state.active && state.child != null) {
          return state.child!;
        }
        return const SizedBox.shrink();
      });
  //builder: (context, state) => state.transitionWidgets(state,
  //    onEntering: state.child!,
  //    onEntered: state.child!,
  //    onExiting: state.child!,
  //    onExited: const SizedBox.shrink()));
}

class WelcomeBackScreen extends StatefulWidget {
  const WelcomeBackScreen({super.key});

  @override
  WelcomeBackScreenState createState() => WelcomeBackScreenState();
}

class WelcomeBackScreenState extends State<WelcomeBackScreen> {
  double _fadingInValue = 1;
  bool _isAnimating = false;
  bool _isFading = false;
  bool _isFadingOut = false;

  @override
  Widget build(BuildContext context) {
    //WidgetsBinding.instance.addPostFrameCallback((_) async {
    //  if (!_isFading && _fadingInValue == 0) {
    //    Future.delayed(fastFadeDuration, () {
    //      setState(() {
    //        _fadingInValue = 1;
    //      });
    //    });
    //  }
    //});
    return AnimatedOpacity(
      opacity: _isFadingOut ? 0 : 1,
      duration: slowFadeDuration,
      child: Stack(
        children: <Widget>[
          AnimatedPositioned(
            duration: slowFadeDuration,
            curve: Curves.easeInOutCubic,
            top: _isAnimating ? screen.height - screen.pane.midHeight : 0,
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
                  color: AppColors.foreground),
              child: AnimatedOpacity(
                opacity: _isFading ? 0 : _fadingInValue,
                duration: slowFadeDuration,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                                padding:
                                    const EdgeInsets.only(top: 8.0, bottom: 0),
                                child: SvgPicture.asset(
                                  LogoIcons.magic,
                                  height: screen.appbar.logoHeight * 2.5,
                                  fit: BoxFit.contain,
                                  alignment: Alignment.center,
                                )),
                            const SizedBox(height: 8),
                            const Text(
                              'Welcome Back',
                              style: TextStyle(
                                fontSize: 24,
                                color: AppColors.subtitle,
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
                              _isFading = true;
                            });
                            print('fading');
                            Future.delayed(slowFadeDuration, () {
                              setState(() {
                                _isAnimating = true;
                              });
                              print('animating');
                              Future.delayed(slowFadeDuration, () {
                                setState(() {
                                  _isFadingOut = true;
                                });
                                Future.delayed(slowFadeDuration, () {
                                  cubits.welcome.update(
                                      active: false,
                                      child: const SizedBox.shrink());
                                  cubits.app.animating = false;
                                  //deriveInBackground();
                                  cubits.receive.populateAddresses(
                                      Blockchain.ravencoinMain);
                                  cubits.receive.populateAddresses(
                                      Blockchain.evrmoreMain);
                                });
                              });
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.button,
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
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
