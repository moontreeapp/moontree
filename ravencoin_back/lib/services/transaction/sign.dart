import 'package:ravencoin_wallet/ravencoin_wallet.dart' as ravencoin;

import 'package:ravencoin_back/ravencoin_back.dart';

extension SignEachInput on ravencoin.TransactionBuilder {
  /// Since addresses don't have access to their private key for signing, we
  /// need to find the keypair for each type of wallet and use it to sign the
  /// inputs.
  /// input order of the created transaction
  Future<void> signEachInput(List<Vout> utxos) async {
    for (var e in utxos.enumerated()) {
      int i = e[0];
      Vout utxo = e[1];
      var keyPair = await services.wallet.getAddressKeypair(utxo.address!);
      sign(
        vin: i,
        keyPair: keyPair,
        prevOutScriptOverride: utxo.isAsset
            ? (utxo.lockingScript == null
                    ? (await services.client.api
                            .getTransaction(utxo.transactionId))
                        .vout[utxo.position]
                        .scriptPubKey
                        .hex
                    : utxo.lockingScript!)
                .hexBytes
            : null,
      );
    }
  }
}
