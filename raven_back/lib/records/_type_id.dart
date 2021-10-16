import 'package:raven/raven.dart';
import 'package:raven/records/password_hash.dart';
import 'package:raven/records/transaction.dart';

class TypeId {
  // Core
  static const Account = 0;
  static const Address = 1;
  static const Balance = 2;
  static const Transaction = 3;
  static const Setting = 4;
  static const Block = 5;
  static const Vin = 6;
  static const Vout = 7;

  // Wallets
  static const SingleWallet = 10;
  static const LeaderWallet = 11;

  // Misc
  static const Rate = 20;
  static const Security = 21;
  static const CipherUpdate = 22;
  static const Password = 23;

  // enums
  static const Net = 100;
  static const NodeExposure = 101;
  static const SecurityType = 102;
  static const SettingName = 103;
  static const CipherType = 104;
}
