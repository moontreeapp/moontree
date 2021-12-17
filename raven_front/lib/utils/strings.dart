import 'package:raven_back/records/net.dart';

class Strings {
  static String whiteSapce = '  ';
  static String punctuationProblematic = '`?:;"\'\\\$|/<>';
  static String punctuationNonProblematic = '~.,-_';
  static String punctuation =
      punctuationProblematic + punctuationNonProblematic + '[]{}()=+*&^%#@!';
  static String punctuationMinusCurrency =
      punctuation.replaceAll('.', '').replaceAll(',', '');
  static String alphanumeric = 'abcdefghijklmnopqrstuvwxyz12345674890';
  static String addressChars = alphanumeric
      .replaceAll('0', '')
      .replaceAll('o', '')
      .replaceAll('l', '')
      .replaceAll('i', '')
      .toUpperCase();
  static String base58 =
      '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
  static String base58Regex = '[a-km-zA-HJ-NP-Z1-9]';
  static String ravenBase58Regex(Net? net) =>
      r'^' + (net == Net.Test ? '(m|n)' : 'R') + r'(' + base58Regex + r'{33})$';
  //static String assetBaseRegex = r'^[a-zA-Z0-9_.]*$';
  static String assetBaseRegex = r'^[A-Z0-9]{1}[A-Z0-9_.]{0,29}[!]{0,1}$';
  static String subAssetBaseRegex =
      r'^[A-Z0-9]{1}[a-zA-Z0-9_./#]{0,29}[!]{0,1}$';
}
