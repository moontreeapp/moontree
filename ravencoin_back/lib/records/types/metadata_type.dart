import 'package:hive/hive.dart';

import '../_type_id.dart';

part 'metadata_type.g.dart';

@HiveType(typeId: TypeId.MetadataType)
enum MetadataType {
  @HiveField(0)
  unknown,

  @HiveField(1)
  jsonString,

  @HiveField(2)
  imagePath,

  // potentially we could have video types, html types, js types, whatever...
}
