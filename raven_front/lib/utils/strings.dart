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
}
