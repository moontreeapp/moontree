import 'package:client_back/client_back.dart';

/// for testing making large transactions
Future<void> fillDatabaseWithLargeSpendables() async {
  await pros.balances.delete();
  await pros.unspents.delete();
  await pros.vouts.delete();
  await pros.vouts.save(Vout(
      transactionId:
          'b1c76d0d4e8019f8dfedb401348caf8229c40aabde0762d738f88f0f0f9efcba',
      position: 0,
      coinValue: 10000000000000000,
      //100,000,128.88355600
      type: '',
      toAddress: pros.wallets.currentWallet.addresses.first
          .address(pros.settings.chain, pros.settings.net),
      assetSecurityId: pros.securities.EVR.id));
  await pros.balances.save(Balance(
      walletId: pros.settings.currentWalletId,
      security: pros.securities.EVR,
      confirmed: 10000000000000000,
      unconfirmed: 0));
  await pros.unspents.save(Unspent(
    walletId: pros.settings.currentWalletId,
    addressId: pros.wallets.currentWallet.addresses.first.id,
    transactionId:
        'b1c76d0d4e8019f8dfedb401348caf8229c40aabde0762d738f88f0f0f9efcba',
    position: 0,
    height: 1,
    value: 10000000000000000,
    symbol: 'EVR',
    chain: Chain.evrmore,
    net: Net.main,
  ));
}
