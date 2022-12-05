import 'package:hive/hive.dart';

import '../_type_id.dart';

part 'net.g.dart';

@HiveType(typeId: TypeId.Net)
enum Net {
  @HiveField(0)
  main,

  @HiveField(1)
  test
}

extension NetExtension on Net {
  String get symbolModifier {
    switch (this) {
      case Net.main:
        return '';
      case Net.test:
        return 't';
    }
  }

  String get key => name;
  String get readable => 'net: $name';
}
