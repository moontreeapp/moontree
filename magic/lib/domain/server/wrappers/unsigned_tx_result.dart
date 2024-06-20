import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/concepts/money/security.dart';
import 'package:magic/domain/server/serverv2_client.dart';
import 'package:magic/domain/wallet/wallets.dart';
import 'package:magic/services/calls/server.dart';

class UnsignedTransactionResultCalled extends ServerCall {
  late List<MnemonicWallet> mnemonicWallets;
  late List<KeypairWallet> keypairWallets;
  late Blockchain blockchain;
  late String symbol;
  late Security? security;
  final String? changeAddress;
  final String? memo;
  final String address;
  final int sats;
  final List<String> roots;
  final List<String> h160s;
  final List<UnsignedTransactionResult> unsignedTransactionResults;
  UnsignedTransactionResultCalled({
    required this.unsignedTransactionResults,
    required this.mnemonicWallets,
    required this.keypairWallets,
    required this.blockchain,
    required this.address,
    required this.sats,
    required this.symbol,
    required this.roots,
    required this.h160s,
    this.changeAddress,
    this.memo,
  });
}
