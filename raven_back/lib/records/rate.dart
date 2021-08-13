import 'package:hive/hive.dart';
import 'package:raven/records/security.dart';

import '_type_id.dart';

part 'rate.g.dart';

@HiveType(typeId: TypeId.Rate)
class Rate {
  @HiveField(0)
  Security base;

  @HiveField(1)
  Security quote;

  @HiveField(2)
  double rate;

  Rate({
    required this.base,
    required this.quote,
    required this.rate,
  });
}
