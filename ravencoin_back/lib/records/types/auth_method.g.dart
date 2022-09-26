// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_method.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AuthMethodAdapter extends TypeAdapter<AuthMethod> {
  @override
  final int typeId = 109;

  @override
  AuthMethod read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AuthMethod.moontreePassword;
      case 1:
        return AuthMethod.nativeSecurity;
      default:
        return AuthMethod.moontreePassword;
    }
  }

  @override
  void write(BinaryWriter writer, AuthMethod obj) {
    switch (obj) {
      case AuthMethod.moontreePassword:
        writer.writeByte(0);
        break;
      case AuthMethod.nativeSecurity:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthMethodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
