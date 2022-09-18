import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

enum AuthenticationResult {
  success,
  failure,
  noSupport,
  noBiometrics,
  error,
}

class LocalAuthApi {
  final _auth = LocalAuthentication();
  AuthenticationResult? reason;

  Future<bool> get canAuthenticateWithBiometrics async {
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      return false;
    }
  }

  Future<bool> get canAuthenticate async =>
      await canAuthenticateWithBiometrics && await _auth.isDeviceSupported();

  Future<List<BiometricType>> get availableBiometrics async =>
      await _auth.getAvailableBiometrics();

  Future<bool> get readyToAuthenticate async {
    bool canAuth = await canAuthenticate;
    if (!canAuth) {
      reason = AuthenticationResult.noSupport;
      return false;
    }
    List<BiometricType> biometrics = await availableBiometrics;
    if (biometrics.isEmpty) {
      reason = AuthenticationResult.noBiometrics;
      return false;
    }
    return true;
  }

  Future<bool> authenticate({bool stickyAuth = false}) async {
    if (!(await readyToAuthenticate)) {
      return false;
    }

    // Some biometrics are enrolled.
    //if (biometrics.contains(BiometricType.strong) ||
    //    biometrics.contains(BiometricType.face)) {
    //  // Specific types of biometrics are available.
    //  // Use checks like this with caution!
    //}
    try {
      if (await _auth.authenticate(
        localizedReason: 'Please Authenticate',
        //Iterable<AuthMessages> authMessages = const <AuthMessages>[IOSAuthMessages(), AndroidAuthMessages(), WindowsAuthMessages()],
        //authMessages: const [
        //  AndroidAuthMessages(
        //    signInTitle: 'Oops! Biometric authentication required!',
        //    cancelButton: 'No thanks',
        //  ),
        //  IOSAuthMessages(
        //    cancelButton: 'No thanks',
        //  ),
        //],
        options: AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: stickyAuth,
          biometricOnly: false,
        ),
      )) {
        reason = AuthenticationResult.success;
        return true;
      }
      reason = AuthenticationResult.failure;
    } on PlatformException catch (e) {
      print(e);
      reason = AuthenticationResult.error;
    }
    return false;
  }
}
