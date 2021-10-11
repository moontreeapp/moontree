import 'package:ravencoin/ravencoin.dart';

import 'package:raven/raven.dart';

extension SignEachInput on TransactionBuilder {
  /// Since addresses don't have access to their private key for signing, we
  /// need to find the keypair for each type of wallet and use it to sign the
  /// inputs.
  /// input order of the created transaction
  void signEachInput(List<History> utxos) {
    utxos.asMap().forEach((i, utxo) {
      var keyPair = services.wallets.getAddressKeypair(utxo.address!);
      var before = tx.toString();
      var after = tx.toString();
      print('BEFORE $before');
      sign(vin: i, keyPair: keyPair);
      print('AFTER  $after');
      print(before == after);
    });
  }
}
