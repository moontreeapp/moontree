import 'package:tuple/tuple.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:wallet_utils/wallet_utils.dart' show ECPair, TransactionBuilder;
import 'package:client_back/client_back.dart';

extension SignEachInput on TransactionBuilder {
  /// Since addresses don't have access to their private key for signing, we
  /// need to find the keypair for each type of wallet and use it to sign the
  /// inputs.
  /// input order of the created transaction
  Future<void> signEachInput(List<Vout> utxos) async {
    for (final Tuple2<int, Vout> e in utxos.enumeratedTuple<Vout>()) {
      final Vout utxo = e.item2;
      final ECPair keypair =
          await services.wallet.getAddressKeypair(utxo.address!);
      print(keypair);
      //sign(
      //  vin: e.item1,
      //  keyPair: await services.wallet.getAddressKeypair(utxo.address!),
      //  prevOutScriptOverride: utxo.isAsset
      //      ? (utxo.lockingScript == null
      //              ? (await services.client.api
      //                      .getTransaction(utxo.transactionId))
      //                  .vout[utxo.position]
      //                  .scriptPubKey
      //                  .hex
      //              : utxo.lockingScript!)
      //          .hexBytes
      //      : null,
      //);
    }
  }
}
