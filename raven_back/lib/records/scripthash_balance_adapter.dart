import 'package:hive/hive.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

class ScripthashBalanceAdapter extends TypeAdapter<ScripthashBalance> {
  @override
  final typeId = 12;

  @override
  ScripthashBalance read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScripthashBalance(
      fields[0] as int,
      fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ScripthashBalance obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.confirmed)
      ..writeByte(1)
      ..write(obj.unconfirmed);
  }
}
