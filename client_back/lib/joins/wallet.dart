part of 'joins.dart';

extension WalletBelongsToCipher on Wallet {
  //CipherBase? get cipher => pros.cipherRegistry.ciphers[cipherUpdate];
  CipherBase? get cipher => cipherUpdate.cipherType == CipherType.none
      ? pros.ciphers.records.firstOrNull?.cipher
      : pros.ciphers.primaryIndex.getOneByCipherUpdate(cipherUpdate)?.cipher;
}

extension WalletHasManyAddresses on Wallet {
  List<Address> get addresses => pros.addresses.byWallet.getAll(id);
}

extension GenerateAddressThruConversion on Wallet {
  Future<Address> get address async {
    final wallet_utils.KPWallet kpWallet =
        await (this as SingleWallet).kpWallet; //getKPWallet(wallet);
    return Address(
        scripthash: kpWallet.scripthash,
        pubkey: kpWallet.pubKey!,
        walletId: id,
        index: 0,
        exposure: NodeExposure.external);
  }
}

extension WalletHasManyAddressesByExposure on Wallet {
  List<Address> addressesBy(NodeExposure exposure, [Chain? chain, Net? net]) =>
      pros.addresses.byWalletExposure.getAll(id, exposure);
}

extension WalletHasOneHighestIndexByExposure on Wallet {
  int highestIndexOf(NodeExposure exposure, [Chain? chain, Net? net]) =>
      addressesBy(exposure, chain, net).fold(
          -1,
          (int previousValue, Address element) =>
              element.index > previousValue ? element.index : previousValue);
}

extension WalletHasManyBalances on Wallet {
  List<Balance> get balances => pros.balances.byWallet.getAll(id);
}

extension WalletHasManyVouts on Wallet {
  Iterable<Vout> get vouts =>
      pros.vouts.records.where((Vout vout) => vout.wallet?.id == id);
}

extension WalletHasManyVins on Wallet {
  Iterable<Vin> get vins =>
      pros.vins.records.where((Vin vin) => vin.wallet?.id == id);
}

extension WalletHasManyTransactions on Wallet {
  Set<Transaction> get transactions {
    try {
      return (vouts.map((Vout vout) => vout.transaction!).toList() +
              vins.map((Vin vin) => vin.transaction!).toList())
          .toSet()
        ..remove(null);
    } catch (e) {
      return <Transaction>{};
    }
  }
}

// would prefer .assets
extension WalletHasManyHoldingCount on Wallet {
  int get holdingCount => vouts
      .map((Vout vout) => vout.assetSecurityId // null is rvn
          )
      .toSet()
      .length;
}

extension WalletHasrvnValue on Wallet {
  int get rvnValue => balances
      .where((Balance b) => b.security.symbol == 'RVN')
      .fold(0, (int running, Balance b) => b.value + running);
}

extension WalletHasCoinValue on Wallet {
  int get coinValue => balances
      .where((Balance b) => b.security == pros.securities.currentCoin)
      .fold(0, (int running, Balance b) => b.value + running);
}

//extension WalletHasAssetValue on Wallet {
//  int get assetValue(Asset asset) => balances
//      .where((Balance b) => b.security.symbol == 'RVN')
//      .fold(0, (running, Balance b) => b.value + running);
//}

// change addresses
extension WalletHasManyInternalAddresses on Wallet {
  Iterable<Address> get internalAddresses => addressesBy(NodeExposure.internal);
}

// receive addresses
extension WalletHasManyExternalAddresses on Wallet {
  Iterable<Address> get externalAddresses => addressesBy(NodeExposure.external);
}

extension WalletHasManyGapAddresses on Wallet {
  Iterable<Address> usedAddresses(
    NodeExposure exposure, [
    Chain? chain,
    Net? net,
  ]) =>
      addressesBy(exposure, chain, net)
          .where((Address address) => address.status?.status != null);

  Iterable<Address> emptyAddresses(
    NodeExposure exposure, [
    Chain? chain,
    Net? net,
  ]) =>
      addressesBy(exposure, chain, net).where((Address address) =>
          address.status != null && address.status!.status == null);

  Address minimumEmptyAddress(
    NodeExposure exposure, {
    Chain? chain,
    Net? net,
  }) {
    final List<Address> x = emptyAddresses(exposure, chain, net).toList();
    // KPWallets have only one address that is probably used
    if (x.isEmpty) {
      return addresses.first;
    }
    final int y = x.fold(
        999999999,
        (int previousValue, Address element) =>
            element.index < previousValue ? element.index : previousValue);
    return x.where((Address element) => element.index == y).first;
  }

  Iterable<Address> emptyAddressesAfterIndex(
    NodeExposure exposure,
    int index, [
    Chain? chain,
    Net? net,
  ]) =>
      addressesBy(exposure, chain, net).where((Address address) =>
          address.index > index && address.status?.status == null);

  int highestUsedIndex(
    NodeExposure exposure, [
    Chain? chain,
    Net? net,
  ]) =>
      usedAddresses(exposure, chain, net).toList().fold(
          -1,
          (int previousValue, Address element) =>
              element.index > previousValue ? element.index : previousValue);

  Iterable<Address> gapAddresses(
    NodeExposure exposure, [
    Chain? chain,
    Net? net,
  ]) =>
      emptyAddressesAfterIndex(
        exposure,
        highestUsedIndex(exposure, chain, net),
        chain,
        net,
      );

  Address firstEmptyInGap(
    NodeExposure exposure, [
    Chain? chain,
    Net? net,
  ]) {
    final List<Address> gap = gapAddresses(exposure, chain, net).toList();
    // KPWallets have only one address that is probably used
    if (gap.isEmpty) {
      return addresses.first;
    }
    final int lowest = gap.fold(double.maxFinite.toInt(),
        (int prev, Address addr) => addr.index < prev ? addr.index : prev);
    return gap.where((Address element) => element.index == lowest).first;
  }
}

extension WalletHasManyEmptyInternalAddresses on Wallet {
  Iterable<Address> get emptyInternalAddresses =>
      addresses.where((Address address) =>
          address.exposure == NodeExposure.internal &&
          address.status?.status == null);
  //internalAddresses.where((address) => address.vouts.isEmpty);
}

extension WalletHasManyEmptyExternalAddresses on Wallet {
  Iterable<Address> get emptyExternalAddresses =>
      addresses.where((Address address) =>
          address.exposure == NodeExposure.external &&
          address.status?.status == null);
  //externalAddresses.where((address) => address.vouts.isEmpty);
}

extension WalletHasManyUsedInternalAddresses on Wallet {
  Iterable<Address> get usedInternalAddresses =>
      addresses.where((Address address) =>
          address.exposure == NodeExposure.internal &&
          address.status?.status != null);
  //internalAddresses.where((address) => address.vouts.isNotEmpty);
}

extension WalletHasManyUsedExternalAddresses on Wallet {
  Iterable<Address> get usedExternalAddresses =>
      addresses.where((Address address) =>
          address.exposure == NodeExposure.external &&
          address.status?.status != null);
  //externalAddresses.where((address) => address.vouts.isNotEmpty);
}

extension WalletHasManyUnspents on Wallet {
  List<Unspent> get unspents => pros.unspents.byWallet.getAll(id);
}

extension WalletMayHaveRoots on Wallet {
  Future<List<String>> get roots async => [];
}

extension LeaderWalletHasTwoRoots on LeaderWallet {
  Future<List<String>> get roots async => [
        await externalRoot,
        await internalRoot,
      ];

  Future<String> get externalRoot async => SeedWallet(
        await seed,
        pros.settings.chain,
        pros.settings.net,
      )
          .wallet
          .derivePath(
            // "m/44'/175'/0'/0"
            getDerivationPath(
              exposure: NodeExposure.external,
              net: pros.settings.net,
            ),
          )
          .base58!;

  Future<String> get internalRoot async => SeedWallet(
        await seed,
        pros.settings.chain,
        pros.settings.net,
      )
          .wallet
          .derivePath(
            //"m/44'/175'/0'/1"
            getDerivationPath(
              exposure: NodeExposure.internal,
              net: pros.settings.net,
            ),
          )
          .base58!;
}
