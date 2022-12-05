import 'package:moontree_utils/extensions/string.dart';

abstract class Concept<T extends Enum> {
  final T option;
  const Concept(this.option);
  String get name => option.name;
  String get nameTitlecase => option.name.toTitleCase();
}
