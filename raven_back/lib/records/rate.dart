import 'package:hive/hive.dart';

part 'rate.g.dart';

@HiveType(typeId: 4)
class Rate {
  @HiveField(0)
  String from;

  @HiveField(1)
  String to;

  @HiveField(2)
  double rate;

  @HiveField(3)
  bool fiat;

  Rate({
    required this.from,
    required this.to,
    required this.rate,
    required this.fiat,
  });
}
