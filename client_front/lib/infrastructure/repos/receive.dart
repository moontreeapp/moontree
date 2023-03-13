import 'package:client_back/records/records.dart';
import 'package:client_back/services/services.dart';
import 'package:client_front/infrastructure/calls/receive.dart';
import 'package:client_front/infrastructure/cache/receive.dart';
import 'package:client_front/infrastructure/repos/repository.dart';
import 'package:client_front/infrastructure/services/lookup.dart';

extension GenerateAddressThruDeriviation on LeaderWallet {
  Future<Address> generateAddress({
    required int index,
    required NodeExposure exposure,
    required Chain chain,
    required Net net,
  }) async =>
      services.wallet.leader.deriveAddressByIndex(
        wallet: this,
        exposure: exposure,
        hdIndex: index,
        chain: chain,
        net: net,
      );
}

extension GenerateAddressThruConversion on SingleWallet {
  Future<Address> get address async => services.wallet.single.toAddress(this);
}

class ReceiveRepo extends Repository<Address> {
  late Wallet wallet;
  late bool change;
  late Chain chain;
  late Net net;
  ReceiveRepo({
    Wallet? wallet,
    this.change = false, // default external
    Chain? chain,
    Net? net,
  }) : super(Address.empty()) {
    this.chain = chain ?? Current.chain;
    this.net = net ?? Current.net;
    this.wallet = wallet ?? Current.wallet;
  }

  @override
  bool detectLocalError(dynamic resultLocal) => resultLocal == null;

  @override
  Future<Address?> fromServer() async {
    if (wallet is LeaderWallet) {
      final index = await ReceiveCall(
        wallet: wallet as LeaderWallet,
        change: change,
        chain: chain,
        net: net,
      )();
      if (index.error != null) {
        return Address.empty().create(error: index.error);
      }
      return (wallet as LeaderWallet).generateAddress(
        index: index.value,
        exposure: change ? NodeExposure.internal : NodeExposure.external,
        chain: chain,
        net: net,
      );
    }
    // not from server, but thats ok.
    return (wallet as SingleWallet).address;
  }

  @override
  Future<Address?> fromLocal() async =>
      ReceiveCache.get(
        wallet: wallet,
        exposure: change ? NodeExposure.internal : NodeExposure.external,
        chain: chain,
        net: net,
      ) ??
      await generateLocally();

  Future<Address>? generateLocally() async {
    if (wallet is LeaderWallet) {
      return await (wallet as LeaderWallet).generateAddress(
        exposure: change ? NodeExposure.internal : NodeExposure.external,
        index: 1,
        chain: chain,
        net: net,
      );
    }
    return (wallet as SingleWallet).address;
  }

  @override
  Future<void> save() async => ReceiveCache.put(
        wallet: wallet,
        //exposure: change ? NodeExposure.internal : NodeExposure.external,
        chain: chain,
        net: net,
        record: results,
      );
}
