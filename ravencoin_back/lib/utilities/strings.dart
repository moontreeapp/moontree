import 'package:quiver/iterables.dart';
import 'package:ravencoin_back/records/types/net.dart';

String whiteSapce = '  ';
String punctuationProblematic = '`?:;"\'\\\$|/<>';
String punctuationNonProblematic = '~.,-_';
String punctuation =
    punctuationProblematic + punctuationNonProblematic + '[]{}()=+*&^%#@!';
String punctuationMinusCurrency =
    punctuation.replaceAll('.', '').replaceAll(',', '');
String alphanumeric = 'abcdefghijklmnopqrstuvwxyz12345674890';
String addressChars = alphanumeric
    .replaceAll('0', '')
    .replaceAll('o', '')
    .replaceAll('l', '')
    .replaceAll('i', '')
    .toUpperCase();
String base58 = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
String base58Regex = '[a-km-zA-HJ-NP-Z1-9]';
String ravenBase58Regex(Net? net) =>
    r'^' + (net == Net.test ? '(m|n)' : 'R') + r'(' + base58Regex + r'{33})$';
String assetBaseRegex = r'^[A-Z0-9]{1}[A-Z0-9_.]{2,29}[!]{0,1}$';
String subAssetBaseRegex = r'^[A-Z0-9]{1}[a-zA-Z0-9_.#]{2,29}[!]{0,1}$';
String mainAssetAllowed = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ._';
String verifierStringAllowed = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ._ (#&|!)';
String evrAirdropTx =
    'c191c775b10d2af1fcccb4121095b2a018f1bee84fa5efb568fcddd383969262';

/*
/// requires 'dart:mirrors' which conflicts with something
/// https://stackoverflow.com/questions/58472589/dart-error-error-import-of-dartmirrors-is-not-supported-in-the-current-dart-r
/// therefore removed
String toStringOverride(object) {
  
  var instance_mirror = reflect(object);
  var class_mirror = instance_mirror.type;
  var ret = [class_mirror.runtimeType.toString()];
  for (var v in class_mirror.declarations.values) {
    var name = MirrorSystem.getName(v.simpleName);
    if (v is VariableMirror) {
      ret.add(
          "${v.isConst ? 'const' : ''} ${v.isStatic ? 'static' : ''} ${v.isFinal ? 'final' : ''} ${v.isPrivate ? 'private' : ''} $name: ${instance_mirror..getField(v.qualifiedName)}");
    }
  }
  return ret.length > 1 ? instance_mirror.toString() : ret.join('\n');
}
*/
String toStringOverride(object, List items, List<String> names) =>
    '${object.runtimeType.toString()}(${[
      for (var z in zip([names, items])) '${z[0]}: ${z[1]}'
    ].join(', ')})';
