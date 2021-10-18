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
      addressId: fields[0] as String,
      txId: fields[1] as String,
      height: fields[2] as int,
      confirmed: fields[3] as bool,
      time: fields[4] as int,
      memo: fields[5] as String?,
      note: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.addressId)
      ..writeByte(1)
      ..write(obj.txId)
      ..writeByte(2)
      ..write(obj.height)
      ..writeByte(3)
      ..write(obj.confirmed)
      ..writeByte(4)
      ..write(obj.time)
      ..writeByte(5)
      ..write(obj.memo)
      ..writeByte(6)
      ..write(obj.note);
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
