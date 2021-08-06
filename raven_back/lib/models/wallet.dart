import 'package:equatable/equatable.dart';
import 'package:raven/cipher.dart';
import 'package:raven/records.dart';
import 'package:ravencoin/ravencoin.dart' show NetworkType;

abstract class Wallet extends Equatable {
  final Net net;
  late final Cipher cipher;

  Wallet({this.net = Net.Test, this.cipher = const NoCipher()}) : super();

  NetworkType get network => networks[net]!;

  @override
  List<Object?> get props => [net];
}
