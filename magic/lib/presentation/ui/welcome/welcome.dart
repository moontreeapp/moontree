import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/toast/cubit.dart';
import 'package:magic/cubits/welcome/cubit.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/presentation/theme/colors.dart';
import 'package:magic/presentation/utils/animation.dart';
import 'package:magic/presentation/widgets/assets/icons.dart';
import 'package:magic/services/services.dart';
import 'package:magic/services/security.dart';
import 'package:url_launcher/url_launcher_string.dart'; // Make sure to import the security service

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

  void _showSecurityWarning(BuildContext context, String warningType) {
    String title;
    String content;
    bool showSettingsButton = false;

    switch (warningType) {
      case 'no_biometrics':
        title = 'Security Warning';
        content =
            'Your device does not support biometric authentication. For optimal security, it is recommended to use this app on a device with biometric capabilities.';
        break;
      case 'no_auth_setup':
        title = 'Security Recommendation';
        content =
            'Your device supports biometric or device authentication, but it\'s not set up. We STRONGLY recommend setting up device security for optimal protection of your sensitive wallet information.';
        showSettingsButton = true;
        break;
      default:
        title = 'Security Notice';
        content =
            'Please ensure your device is properly secured for the best protection of your sensitive information.';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            if (showSettingsButton)
              TextButton(
                child: const Text('Open Settings'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _openSecuritySettings();
                },
              ),
            TextButton(
              child: const Text('Understood'),
              onPressed: () {
                Navigator.of(context).pop();
                _proceedToMainApp();
              },
            ),
          ],
        );
      },
    );
  }

  void _openSecuritySettings() async {
    if (Platform.isAndroid) {
      const platform = MethodChannel('com.magic.mobile/settings');
      try {
        await platform.invokeMethod('openSecuritySettings');
      } on PlatformException catch (e) {
        print("Failed to open security settings: '${e.message}'.");
      }
    } else if (Platform.isIOS) {
      if (await canLaunchUrlString('App-Prefs:root=TOUCHID_PASSCODE')) {
        await launchUrlString('App-Prefs:root=TOUCHID_PASSCODE');
      } else {
        print('Could not launch iOS settings');
      }
    }
  }

  Future<void> _handleAuthentication() async {
    bool supportsBiometrics = await securityService.canCheckBiometrics();
    bool isAuthSetUp = await securityService.isAuthenticationSetUp();
    bool isAuthenticated = await securityService.authenticateUser();
    print('isAuthenticated: $isAuthenticated');
    if (isAuthenticated) {
      if (!supportsBiometrics) {
        _showSecurityWarning(context, 'no_biometrics');
      } else if (!isAuthSetUp) {
        _showSecurityWarning(context, 'no_auth_setup');
      } else {
        /// moved to main.dart
        //await cubits.keys.load();
        //await subscription.ensureConnected();
        //subscription.setupSubscriptions(cubits.keys.master);
        //cubits.wallet.populateAssets().then((_) => maestro.activateHome());
        _proceedToMainApp();
      }
    } else {
      cubits.toast.flash(
          msg: const ToastMessage(
        title: 'Authentication Failed:',
        text: 'Please try again.',
      ));
    }
  }

  void _proceedToMainApp() {
    cubits.app.animating = true;
    setState(() {
      _isFading = true;
    });
    Future.delayed(slowFadeDuration, () {
      setState(() {
        _isAnimating = true;
      });
      Future.delayed(slowFadeDuration, () {
        setState(() {
          _isFadingOut = true;
        });
        Future.delayed(slowFadeDuration, () {
          cubits.welcome.update(active: false, child: const SizedBox.shrink());
          cubits.app.animating = false;
          //deriveInBackground();
          cubits.receive.deriveAll([
            Blockchain.ravencoinMain,
            Blockchain.evrmoreMain,
          ]);
          cubits.receive.populateAddresses(Blockchain.ravencoinMain);
          cubits.receive.populateAddresses(Blockchain.evrmoreMain);
        });
      });
    });
  }

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
              height: Platform.isAndroid
                  ? MediaQuery.of(context).size.height
                  : screen.height,
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
                              'Welcome',
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
                          onPressed: _handleAuthentication, // Changed this line
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
