import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/services/wallet/constants.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart';

export 'extended_wallet_base.dart';

abstract class Wallet with HiveObjectMixin, EquatableMixin {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final CipherUpdate cipherUpdate;

  @HiveField(2)
  final String name;

  @HiveField(3)
  int highestUsedExternalIndex;

  @HiveField(4)
  int highestSavedExternalIndex;

  @HiveField(5)
  int highestUsedInternalIndex;

  @HiveField(6)
  int highestSavedInternalIndex;

  @override
  List<Object?> get props => [id, cipherUpdate, name];

  Wallet({
    required this.id,
    required this.cipherUpdate,
    String? name,
    this.highestUsedExternalIndex = 0,
    this.highestSavedExternalIndex = 0,
    this.highestUsedInternalIndex = 0,
    this.highestSavedInternalIndex = 0,
  }) : name = name ?? (id.length > 5 ? id.substring(0, 6) : id[0]);

  String get encrypted;

  String secret(CipherBase cipher);

  WalletBase seedWallet(CipherBase cipher, {Net net = Net.Main});

  SecretType get secretType => SecretType.none;

  WalletType get walletType => WalletType.none;

  String get publicKey => id;

  String get secretTypeToString => secretType.enumString;
  String get walletTypeToString => walletType.enumString;

  /// caching optimization
  int currentGap(NodeExposure exposure) => exposure == NodeExposure.External
      ? highestSavedExternalIndex - highestUsedExternalIndex
      : highestSavedInternalIndex - highestUsedInternalIndex;

  int getHighestSavedIndex(NodeExposure exposure) =>
      exposure == NodeExposure.Internal
          ? highestSavedInternalIndex
          : highestSavedExternalIndex;

  int getHighestUsedIndex(NodeExposure exposure) =>
      exposure == NodeExposure.Internal
          ? highestUsedInternalIndex
          : highestUsedExternalIndex;

  /// only updates if it's larger
  /// not sure you can call res.wallets.save from here.
  void updateHighestUsedIndex(int value, NodeExposure exposure) {
    if (this is LeaderWallet) {
      if (exposure == NodeExposure.Internal) {
        if (value > highestUsedInternalIndex) {
          res.wallets.save(LeaderWallet.from(
            this as LeaderWallet,
            highestUsedInternalIndex: value,
          ));
        }
      } else {
        if (value > highestUsedExternalIndex) {
          res.wallets.save(LeaderWallet.from(
            this as LeaderWallet,
            highestUsedExternalIndex: value,
          ));
        }
      }
    }
  }
}
