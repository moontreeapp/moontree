import 'dart:convert';
import 'package:magic/domain/blockchain/blockchain.dart';

class ChainPub {
  final String xpub;
  final Blockchain blockchain;

  ChainPub({required this.xpub, required this.blockchain});

  factory ChainPub.fromJson(String json) {
    final Map<String, String> decoded = jsonDecode(json);
    return ChainPub(
      xpub: decoded['xpub']!,
      blockchain: Blockchain.from(name: decoded['blockchain']!),
    );
  }

  Map<String, String> get asMap => {
        'xpub': xpub,
        'blockchain': blockchain.name,
      };
}
