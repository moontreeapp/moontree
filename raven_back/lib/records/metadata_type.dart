import 'package:hive/hive.dart';

import '_type_id.dart';

part 'metadata_type.g.dart';

@HiveType(typeId: TypeId.MetadataType)
enum MetadataType {
  @HiveField(0)
  Unknown,

  @HiveField(1)
  JsonString,

  @HiveField(2)
  ImagePath,

  // potentially we could have video types, html types, js types, whatever...
}
