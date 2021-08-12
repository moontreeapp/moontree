// unused at this time

import 'package:ravencoin/ravencoin.dart' as ravencoin;
import 'package:raven/records.dart';
import 'package:raven/reservoirs.dart';
import 'package:raven/services/service.dart';
import 'package:raven/utils/derivation_path.dart';

class WalletDerivationUnit extends Unit {
  AccountReservoir accounts;
  LeaderWalletReservoir leaders;
  SingleWalletReservoir singles;
  AddressReservoir addresses;

  WalletDerivationUnit(
    this.accounts,
    this.leaders,
    this.singles,
    this.addresses,
  ) : super();

  ravencoin.HDWallet getChangeWallet(LeaderWallet wallet, Net net) {
    var seededWallet =
        ravencoin.HDWallet.fromSeed(wallet.seed, network: networks[net]!);
    return seededWallet.derivePath(getDerivationPath(
        addresses.byWalletExposure
            .getAll('${wallet.id}:${NodeExposure.Internal}')
            .length,
        exposure: NodeExposure.Internal));
  }

  ravencoin.KPWallet getSingleChangeWallet(SingleWallet wallet, Net net) {
    return ravencoin.KPWallet(
        ravencoin.ECPair.fromPrivateKey(wallet.privateKey,
            network: networks[net]!, compressed: true),
        ravencoin.P2PKH(data: ravencoin.PaymentData(), network: networks[net]!),
        networks[net]!);
  }

  Address getChangeAddress(String walletId) {
    var wallet = leaders.get(walletId);
    if (wallet == null) {
      var wallet = singles.get(walletId)!;
      var net = accounts.get(wallet.accountId)!.net;
      var seededWallet = getSingleChangeWallet(wallet, net);
      return Address(
          scripthash: seededWallet.scripthash,
          address: seededWallet.address!,
          walletId: wallet.id,
          accountId: wallet.accountId,
          hdIndex: 0,
          net: net);
    }
    var net = accounts.get(wallet.accountId)!.net;
    var seededWallet = getChangeWallet(wallet, net);
    return Address(
        scripthash: seededWallet.scripthash,
        address: seededWallet.address!,
        walletId: wallet.id,
        accountId: wallet.accountId,
        hdIndex: addresses.byWalletExposure
            .getAll('${wallet.id}:${NodeExposure.Internal}')
            .length,
        exposure: NodeExposure.Internal,
        net: net);
  }

  ravencoin.HDWallet deriveWallet(LeaderWallet wallet, Net net, int hdIndex,
      [exposure = NodeExposure.External]) {
    var seededWallet =
        ravencoin.HDWallet.fromSeed(wallet.seed, network: networks[net]!);
    return seededWallet
        .derivePath(getDerivationPath(hdIndex, exposure: exposure));
  }

  Address deriveAddress(String walletId, int hdIndex, NodeExposure exposure) {
    var wallet = leaders.get(walletId)!;
    var net = accounts.get(wallet.accountId)!.net;
    var seededWallet = deriveWallet(wallet, net, hdIndex, exposure);
    if (wallet is SingleWallet) {
      return Address(
          scripthash: seededWallet.scripthash,
          address: seededWallet.address!,
          walletId: wallet.id,
          accountId: wallet.accountId,
          hdIndex: 0,
          net: net);
    }
    return Address(
        scripthash: seededWallet.scripthash,
        address: seededWallet.address!,
        walletId: wallet.id,
        accountId: wallet.accountId,
        hdIndex: hdIndex,
        exposure: exposure,
        net: net);
  }
}
