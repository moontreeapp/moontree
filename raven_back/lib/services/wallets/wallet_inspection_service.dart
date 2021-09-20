import 'package:raven/records/records.dart';
import 'package:raven/reservoirs/reservoirs.dart';
import 'package:raven/services/service.dart';

class walletInspectionService extends Service {
  late WalletReservoir wallets;

  walletInspectionService(this.wallets) : super();

  Set<CipherUpdate> get getCurrentCipherUpdates =>
      wallets.data.map((wallet) => wallet.cipherUpdate).toSet();
}
