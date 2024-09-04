import 'package:magic/domain/concepts/money/security.dart';
import 'package:magic/domain/server/serverv2_client.dart';
import 'package:magic/domain/wallet/wallets.dart';
import 'package:magic/services/calls/server.dart';

class UnsignedTransactionResultCalled extends ServerCall {
  final List<UnsignedTransactionResult> unsignedTransactionResults;
  late List<DerivationWallet> derivationWallets;
  late List<KeypairWallet> keypairWallets;
  late Security security;
  final String changeAddress;
  final String address;
  final int sats;
  final List<String> roots;
  final List<String> h160s;
  final String? memo;
  UnsignedTransactionResultCalled({
    required this.unsignedTransactionResults,
    required this.derivationWallets,
    required this.keypairWallets,
    required this.address,
    required this.sats,
    required this.security,
    required this.roots,
    required this.h160s,
    required this.changeAddress,
    this.memo,
  });
}
