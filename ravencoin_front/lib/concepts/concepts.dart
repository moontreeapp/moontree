import 'package:ravencoin_front/concepts/fee.dart';

//class Concept {
//  final option;
//  String get name => option!.name;
//  const Concept(this.option);
//}
abstract class Concept<T extends Enum> {
  final T option;
  const Concept(this.option);
  String get name => option.name;
}
