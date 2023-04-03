// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_level.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FeatureLevelAdapter extends TypeAdapter<FeatureLevel> {
  @override
  final int typeId = 110;

  @override
  FeatureLevel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FeatureLevel.easy;
      case 1:
        return FeatureLevel.normal;
      case 2:
        return FeatureLevel.expert;
      default:
        return FeatureLevel.easy;
    }
  }

  @override
  void write(BinaryWriter writer, FeatureLevel obj) {
    switch (obj) {
      case FeatureLevel.easy:
        writer.writeByte(0);
        break;
      case FeatureLevel.normal:
        writer.writeByte(1);
        break;
      case FeatureLevel.expert:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeatureLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
