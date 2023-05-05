import 'package:moontree_utils/moontree_utils.dart';
import 'package:client_back/client_back.dart' show pros;
import 'package:client_back/records/address.dart';
import 'package:client_back/records/types/chain.dart';
import 'package:client_back/records/types/node_exposure.dart';
import 'package:client_back/records/wallets/leader.dart';
import 'package:client_front/infrastructure/repos/receive.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;

Future<void> preDeriveInBackground(
        LeaderWallet wallet, ChainNet chainNet) async =>
    await Future(() => preDerive(wallet, chainNet));

Future<void> preDerive(LeaderWallet wallet, ChainNet chainNet) async {
  components.cubits.receiveView.setAddress(wallet, force: true);
  final externalAddress =
      await ReceiveRepo(wallet: wallet, change: false).fetch();
  final internalAddress =
      await ReceiveRepo(wallet: wallet, change: true).fetch();
  print(pros.addresses.primaryIndex.keys);
  print(externalAddress);
  print(internalAddress);
  final externalNeed = range(externalAddress.index + 20);
  final internalNeed = range(internalAddress.index + 20);
  for (final Address address in pros.addresses.primaryIndex.values) {
    if (address.exposure == NodeExposure.external) {
      externalNeed.remove(address.index);
    }
    if (address.exposure == NodeExposure.internal) {
      internalNeed.remove(address.index);
    }
  }
  for (final x in externalNeed) {
    await Future.delayed(Duration(seconds: 1));
    await pros.addresses.save(await wallet.generateAddress(
      index: x,
      exposure: NodeExposure.external,
      chain: chainNet.chain,
      net: chainNet.net,
    ));
  }
  for (final i in internalNeed) {
    await Future.delayed(Duration(seconds: 1));
    await pros.addresses.save(await wallet.generateAddress(
      index: i,
      exposure: NodeExposure.internal,
      chain: chainNet.chain,
      net: chainNet.net,
    ));
  }
}
