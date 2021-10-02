class Strings {
  static String whiteSapce = '  ';
  static String punctuationProblematic = '`?:;"\'\\\$|/<>';
  static String punctuationNonProblematic = '~.,-_';
  static String punctuation =
      punctuationProblematic + punctuationNonProblematic + '[]{}()=+*&^%#@!';
  static String punctuationMinusCurrency =
      punctuation.replaceAll('.', '').replaceAll(',', '');
}
