import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:local_auth/local_auth.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/utils/log.dart';

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
    _checkBiometrics().then((_) {
      _authenticate();
    });
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
