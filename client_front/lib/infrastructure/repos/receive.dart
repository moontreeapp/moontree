import 'package:client_back/records/records.dart';
import 'package:client_back/services/services.dart';
import 'package:client_front/infrastructure/calls/receive.dart';
import 'package:client_front/infrastructure/cache/receive.dart';
import 'package:client_front/infrastructure/repos/repository.dart';
import 'package:client_front/infrastructure/services/lookup.dart';

extension GenerateAddressThruDeriviation on LeaderWallet {
  Future<Address> generateExternalAddress({
    required int index,
    required Chain chain,
    required Net net,
  }) async =>
      services.wallet.leader.deriveAddressByIndex(
        wallet: this,
        exposure: NodeExposure.external,
        hdIndex: index,
        chain: chain,
        net: net,
      );
}

class ReceiveRepo extends Repository<Address> {
  late Wallet wallet;
  late Chain chain;
  late Net net;
  ReceiveRepo({
    Wallet? wallet,
    Chain? chain,
    Net? net,
  }) : super(Address.empty()) {
    this.chain = chain ?? Current.chain;
    this.net = net ?? Current.net;
    this.wallet = wallet ?? Current.wallet;
  }

  @override
  bool detectServerError(dynamic resultServer) => resultServer == null;

  @override
  bool detectLocalError(dynamic resultLocal) => resultLocal == null;

  @override
  String extractError(dynamic resultServer) => 'unknown error';

  @override
  Future<Address?> fromServer() async {
    if (wallet is LeaderWallet) {
      final index = await ReceiveCall(
        wallet: wallet as LeaderWallet,
        chain: chain,
        net: net,
      )();
      if (index.error != null) {
        return null; // losing error infomation here..
      }
      // otherwise convert to address...
      return (wallet as LeaderWallet).generateExternalAddress(
        index: index.value,
        chain: chain,
        net: net,
      );
    } else {
      // TODO: how should we access single wallet's address?
      // return wallet.addresses.first;
      return Address.empty();
    }
  }

  @override
  Address? fromLocal() =>
      ReceiveCache.get(wallet: wallet, chain: chain, net: net);

  @override
  Future<void> save() async => ReceiveCache.put(
        wallet: wallet,
        chain: chain,
        net: net,
        record: results,
      );
}
