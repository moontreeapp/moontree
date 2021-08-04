import 'package:raven/reservoir/reservoir.dart';

class WalletReservoir<Record, Model> extends Reservoir {
  WalletReservoir(source, [mapToModel, mapToRecord])
      : super(source, (wallet) => wallet.id, [mapToModel, mapToRecord]);
}
