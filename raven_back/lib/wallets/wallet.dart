import 'package:equatable/equatable.dart';
import 'package:raven/records.dart';
import 'package:ravencoin/ravencoin.dart' show NetworkType;

class Wallet extends Equatable {
  final Net net;
  // does a wallet have a seed always?
  // or does it sometimes just have a private key?

  Wallet({this.net = Net.Test}) : super();

  NetworkType get network => networks[net]!;

  @override
  List<Object?> get props => [net];
}
