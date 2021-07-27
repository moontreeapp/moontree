/// should this be generated?

import 'package:hive/hive.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

class ScripthashHistoryAdapter extends TypeAdapter<ScripthashHistory> {
  @override
  final typeId = 6;

  @override
  ScripthashHistory read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScripthashHistory(
      height: fields[0] as int,
      txHash: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ScripthashHistory obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.height)
      ..writeByte(1)
      ..write(obj.txHash);
  }
}
