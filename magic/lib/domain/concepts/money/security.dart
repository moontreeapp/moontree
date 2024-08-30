import 'package:equatable/equatable.dart';
import 'package:magic/domain/blockchain/blockchain.dart';

class Security with EquatableMixin {
  final String symbol;
  final Blockchain blockchain;

  const Security({
    required this.symbol,
    required this.blockchain,
  });

  factory Security.fromSecurity(
    Security other, {
    String? symbol,
    Blockchain? blockchain,
  }) =>
      Security(
        symbol: symbol ?? other.symbol,
        blockchain: blockchain ?? other.blockchain,
      );

  factory Security.from(
    Security security, {
    String? symbol,
    Blockchain? blockchain,
  }) {
    return Security(
      symbol: symbol ?? security.symbol,
      blockchain: blockchain ?? security.blockchain,
    );
  }

  @override
  List<Object> get props => <Object>[symbol, blockchain];

  @override
  String toString() => 'Security(symbol: $symbol, '
      'blockchain: $blockchain)';

  /// todo identify a ipfs hash correctly...
  // https://ethereum.stackexchange.com/questions/17094/how-to-store-ipfs-hash-using-bytes32/17112#17112

  bool get isFiat => blockchain == Blockchain.none;
  bool get isCoin => blockchain.symbol == symbol;
  bool get isAsset => !isFiat && !isCoin;
}
