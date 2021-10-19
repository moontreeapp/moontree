import 'package:ravencoin/ravencoin.dart' as ravencoin;

import 'package:raven/raven.dart';

extension SignEachInput on ravencoin.TransactionBuilder {
  /// Since addresses don't have access to their private key for signing, we
  /// need to find the keypair for each type of wallet and use it to sign the
  /// inputs.
  /// input order of the created transaction
  void signEachInput(List<Vout> utxos) {
    utxos.asMap().forEach((i, utxo) {
      var keyPair = services.wallets.getAddressKeypair(utxo.address!);
      sign(vin: i, keyPair: keyPair);
    });
  }
}
