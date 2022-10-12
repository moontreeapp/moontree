// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 3;

  @override
  Transaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Transaction(
      id: fields[0] as String,
      confirmed: fields[1] as bool,
      time: fields[2] as int?,
      height: fields[3] as int?,
      chain: fields[4] == null ? Chain.ravencoin : fields[4] as Chain,
      net: fields[5] == null ? Net.Main : fields[5] as Net,
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.confirmed)
      ..writeByte(2)
      ..write(obj.time)
      ..writeByte(3)
      ..write(obj.height)
      ..writeByte(4)
      ..write(obj.chain)
      ..writeByte(5)
      ..write(obj.net);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
