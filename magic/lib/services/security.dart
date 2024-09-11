import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:magic/domain/storage/secure.dart';
import 'package:magic/services/services.dart' show secureStorage;

class SecurityService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } on PlatformException catch (_) {
      return false;
    }
  }

  Future<bool> isAuthenticationPresent() async {
    try {
      List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty ||
          await _localAuth.isDeviceSupported();
    } on PlatformException catch (_) {
      return false;
    }
  }

  Future<bool> authenticateUser({bool? canCheckBio, bool? isAuthSetup}) async {
    canCheckBio = canCheckBio ?? await canCheckBiometrics();
    isAuthSetup = isAuthSetup ?? await isAuthenticationPresent();

    if (!canCheckBio || !isAuthSetup) {
      // Device doesn't support biometrics or auth is not set up
      return true;
    }

    try {
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access the app',
        //options: const AuthenticationOptions(
        //  stickyAuth: true,
        //  biometricOnly: false,
        //),
      );
      if (authenticated) {
        await _setUserAuthenticated();
      }
      return authenticated;
    } on PlatformException catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> hasUserAuthenticated() async =>
      await secureStorage.read(key: SecureStorageKey.authed.key()) == 'true';

  Future<void> _setUserAuthenticated() async => await secureStorage.write(
      key: SecureStorageKey.authed.key(), value: 'true');

  Future<void> clearAuthentication() async =>
      await secureStorage.delete(key: SecureStorageKey.authed.key());
}

final securityService = SecurityService();
