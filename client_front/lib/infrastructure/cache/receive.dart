import 'package:client_back/client_back.dart';
import 'package:collection/collection.dart';

class ReceiveCache {
  /// accepts a list of BalanceView objects and saves them as balances in cache
  static Future<void> put({
    required Wallet wallet,
    required Chain chain,
    required Net net,
    required Address record,
  }) async {
    //await Cache.save(
    //  record,
    //  'Address',
    //  walletId: wallet.id,
    //  chain: chain,
    //  net: net,
    //  saveSymbols: true,
    //);
    await pros.addresses.save(record);
  }

  /// gets list of BalanceView objects from cache
  static Address? get({
    required Wallet wallet,
    required Chain chain,
    required Net net,
  }) => // addresses concept needs to change.
      pros.addresses.byWalletExposureChainNet
          .getAll(wallet.id, NodeExposure.external, chain, net)
          .firstOrNull;
}
