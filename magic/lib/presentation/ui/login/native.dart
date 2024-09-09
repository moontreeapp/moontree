import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MethodChannel, PlatformException;
import 'package:local_auth/local_auth.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/toast/cubit.dart';
import 'package:magic/services/security.dart';
import 'package:magic/utils/log.dart';
import 'package:url_launcher/url_launcher_string.dart';

class LoginNative extends StatefulWidget {
  final Widget child;
  final Function? onFailure;
  const LoginNative({
    super.key,
    this.child = const SizedBox.shrink(),
    this.onFailure,
  });

  @override
  LoginNativeState createState() => LoginNativeState();
}

class LoginNativeState extends State<LoginNative> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isAuthenticated = false;
  bool _canCheckBiometrics = false;
  bool _isDeviceSupported = false;

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
                _proceed();
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
        see("Failed to open security settings: '${e.message}'.");
      }
    } else if (Platform.isIOS) {
      if (await canLaunchUrlString('App-Prefs:root=TOUCHID_PASSCODE')) {
        await launchUrlString('App-Prefs:root=TOUCHID_PASSCODE');
      } else {
        see('Could not launch iOS settings');
      }
    }
  }

  Future<void> _handleAuthentication() async {
    bool supportsBiometrics = await securityService.canCheckBiometrics();
    bool isAuthSetUp = await securityService.isAuthenticationSetUp();
    bool isAuthenticated = await securityService.authenticateUser();
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
        _proceed();
      }
    } else {
      if (!isAuthenticated) {
        //_showAuthCanceledDialog();
        //cubits.welcome.update(active: true, child: const SizedBox.shrink());
        if (widget.onFailure != null) {
          widget.onFailure!();
        }
      }
      cubits.toast.flash(
          msg: const ToastMessage(
        title: 'Authentication Failed:',
        text: 'Please try again.',
      ));
    }
  }

  Future<void> _checkBiometrics() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      setState(() {
        _canCheckBiometrics = canCheckBiometrics;
        _isDeviceSupported = isDeviceSupported;
      });
    } catch (e) {
      see(e);
    }
  }

  Future<void> _proceed() async {
    setState(() {
      _isAuthenticated = true;
    });
  }

  Future<void> _authenticate() async {
    try {
      if (_canCheckBiometrics || _isDeviceSupported) {
        final isAuthenticated = await _localAuth.authenticate(
          localizedReason: 'Please authenticate to access this feature',
          options: const AuthenticationOptions(
            useErrorDialogs: true,
            stickyAuth: true,
          ),
        );

        setState(() {
          _isAuthenticated = isAuthenticated;
        });

        if (!isAuthenticated) {
          //_showAuthCanceledDialog();
          //cubits.welcome.update(active: true, child: const SizedBox.shrink());
          if (widget.onFailure != null) {
            widget.onFailure!();
          }
        }
      } else {
        _showNoBiometricsDialog();
      }
    } on PlatformException catch (e) {
      // Handle specific exceptions related to local_auth
      if (e.code == 'NotEnrolled' ||
          e.code == 'LockedOut' ||
          e.code == 'PermanentlyLockedOut' ||
          e.code == 'NotAvailable' ||
          e.code == 'OtherOperatingSystem') {
        _showNoBiometricsDialog();
      } else if (e.code == 'userCanceled' || e.code == 'userFallback') {
        // Handle user cancellation
        _showAuthCanceledDialog();
      }
    } catch (e) {
      // Handle other errors
      see(e);
    }
  }

  void _showNoBiometricsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Biometric Authentication Available'),
        content: const Text(
            'Your device does not support biometric authentication or it is not set up. Please set up device security in your settings.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAuthCanceledDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Authentication Canceled'),
        content: const Text(
            'You have canceled the authentication process. Please authenticate to continue.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Optionally, you can navigate back or take other actions
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    //_checkBiometrics().then((_) {
    _handleAuthentication();
    //});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //WidgetsBinding.instance.addPostFrameCallback((_) {
    //  if (!_isAuthenticated) {
    //    if (widget.onFailure != null) {
    //      widget.onFailure!();
    //    }
    //  }
    //});
    if (_isAuthenticated) {
      return widget.child;
    }
    return const SizedBox.shrink();
  }
}

Future<bool> nativeLoginFunction(BuildContext context) async {
  final LocalAuthentication localAuth = LocalAuthentication();
  bool canCheckBiometrics = false;
  bool isDeviceSupported = false;

  Future<void> checkBiometrics() async {
    try {
      canCheckBiometrics = await localAuth.canCheckBiometrics;
      isDeviceSupported = await localAuth.isDeviceSupported();
    } catch (e) {
      see(e);
    }
  }

  void showNoBiometricsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Biometric Authentication Available'),
        content: const Text(
            'Your device does not support biometric authentication or it is not set up. Please set up device security in your settings.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void showAuthCanceledDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Authentication Canceled'),
        content: const Text(
            'You have canceled the authentication process. Please authenticate to continue.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Optionally, you can navigate back or take other actions
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<bool> authenticate() async {
    try {
      if (canCheckBiometrics || isDeviceSupported) {
        final isAuthenticated = await localAuth.authenticate(
          localizedReason: 'Please authenticate to access this feature',
          options: const AuthenticationOptions(
            useErrorDialogs: true,
            stickyAuth: true,
          ),
        );
        if (!isAuthenticated) {
          return false;
        }
        return true;
      } else {
        showNoBiometricsDialog();
      }
    } on PlatformException catch (e) {
      // Handle specific exceptions related to local_auth
      if (e.code == 'NotEnrolled' ||
          e.code == 'LockedOut' ||
          e.code == 'PermanentlyLockedOut' ||
          e.code == 'NotAvailable' ||
          e.code == 'OtherOperatingSystem') {
        showNoBiometricsDialog();
      } else if (e.code == 'userCanceled' || e.code == 'userFallback') {
        // Handle user cancellation
        showAuthCanceledDialog();
      }
    } catch (e) {
      // Handle other errors
      see(e);
    }
    return true;
  }

  await checkBiometrics();
  return await authenticate();
}
