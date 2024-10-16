import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:magic/domain/concepts/storage.dart';
import 'package:magic/services/services.dart' show storage;

class SecurityService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } on PlatformException catch (_) {
      return false;
    }
  }

  Future<bool> isAuthenticationSetUp() async {
    try {
      List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty ||
          await _localAuth.isDeviceSupported();
    } on PlatformException catch (_) {
      return false;
    }
  }

  Future<bool> authenticateUser() async {
    bool canCheckBio = await canCheckBiometrics();
    bool isAuthSetUp = await isAuthenticationSetUp();

    if (!canCheckBio || !isAuthSetUp) {
      // Device doesn't support biometrics or auth is not set up
      return true;
    }

    try {
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access the app',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      if (authenticated) {
        await _setUserAuthenticated();
      }
      return authenticated;
    } on PlatformException catch (_) {
      return false;
    }
  }

  Future<bool> hasUserAuthenticated() async =>
      await storage.read(key: StorageKey.authed.key()) == 'true';

  Future<void> _setUserAuthenticated() async =>
      await storage.write(key: StorageKey.authed.key(), value: 'true');

  Future<void> clearAuthentication() async =>
      await storage.delete(key: StorageKey.authed.key());
}

final securityService = SecurityService();
