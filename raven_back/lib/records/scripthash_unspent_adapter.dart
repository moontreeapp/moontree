/// should this be generated?

import 'package:hive/hive.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

class ScripthashUnspentAdapter extends TypeAdapter<ScripthashUnspent> {
  @override
  final typeId = 7;

  @override
  ScripthashUnspent read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScripthashUnspent(
      scripthash: fields[0] as String,
      height: fields[1] as int,
      txHash: fields[2] as String,
      txPos: fields[3] as int,
      value: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ScripthashUnspent obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.scripthash)
      ..writeByte(1)
      ..write(obj.height)
      ..writeByte(2)
      ..write(obj.txHash)
      ..writeByte(3)
      ..write(obj.txPos)
      ..writeByte(4)
      ..write(obj.value);
  }
}
