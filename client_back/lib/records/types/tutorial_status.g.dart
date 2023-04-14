// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tutorial_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TutorialStatusAdapter extends TypeAdapter<TutorialStatus> {
  @override
  final int typeId = 111;

  @override
  TutorialStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TutorialStatus.blockchain;
      case 1:
        return TutorialStatus.wallet;
      default:
        return TutorialStatus.blockchain;
    }
  }

  @override
  void write(BinaryWriter writer, TutorialStatus obj) {
    switch (obj) {
      case TutorialStatus.blockchain:
        writer.writeByte(0);
        break;
      case TutorialStatus.wallet:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TutorialStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
