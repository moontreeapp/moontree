// ignore_for_file: avoid_classes_with_only_static_members, camel_case_types

import 'authentication.dart';
import 'balance.dart';
import 'cipher.dart';
import 'conversion.dart';
import 'developer.dart';
import 'password.dart';
import 'version.dart';
import 'wallet.dart';

class services {
  static BalanceService balance = BalanceService();
  static CipherService cipher = CipherService();
  static WalletService wallet = WalletService();
  static PasswordService password = PasswordService();
  static AuthenticationService authentication = AuthenticationService();
  static VersionService version = VersionService();
  static DeveloperService developer = DeveloperService();
  static ConversionService conversion = ConversionService();
}
