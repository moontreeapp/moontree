import 'package:collection/collection.dart';
import 'package:magic/cubits/toast/cubit.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/blockchain/exposure.dart';
import 'package:magic/domain/concepts/balance_address.dart';
import 'package:magic/domain/concepts/holding.dart';
import 'package:magic/domain/wallet/extended_wallet_base.dart';
import 'package:magic/domain/wallet/wallets.dart';
import 'package:magic/presentation/utils/animation.dart';
import 'package:magic/domain/storage/secure.dart';
import 'package:wallet_utils/wallet_utils.dart';
import 'package:magic/services/services.dart';
import 'package:magic/cubits/fade/cubit.dart';
import 'package:magic/services/satori.dart';
import 'package:magic/cubits/mixins.dart';
import 'package:equatable/equatable.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/utils/logger.dart';

part 'state.dart';

class PoolCubit extends UpdatableCubit<PoolState> {
  PoolCubit() : super(const PoolState());
  double height = 0;

  @override
  String get key => 'pool';

  @override
  void reset() => emit(const PoolState());

  @override
  void setState(PoolState state) => emit(state);

  @override
  void hide() => update(active: false);

  @override
  void refresh() {
    update(isSubmitting: false);
    update(isSubmitting: true);
  }

  @override
  void activate() => update(active: true);

  @override
  void deactivate() => update(active: false);

  @override
  void update({
    bool? active,
    String? amount,
    Holding? pooHolding,
    List<BalanceAddress>? balanceAddresses,
    String? poolAddress,
    bool? isSubmitting,
    PoolStatus? poolStatus,
    PoolState? prior,
  }) {
    emit(PoolState(
      active: active ?? state.active,
      amount: amount ?? state.amount,
      poolHolding: pooHolding ?? state.poolHolding,
      balanceAddresses: balanceAddresses ?? state.balanceAddresses,
      poolAddress: poolAddress ?? state.poolAddress,
      isSubmitting: isSubmitting ?? state.isSubmitting,
      poolStatus: poolStatus ?? state.poolStatus,
      prior: prior ?? state.withoutPrior,
    ));
  }

  void setPoolAddress() {
    var satoriData = state.balanceAddresses?.firstWhereOrNull(
      (element) => element.symbol.toLowerCase() == 'satori',
    );
    if (satoriData != null && satoriData.addresses.isNotEmpty) {
      update(poolAddress: satoriData.addresses.first);
    }
  }

  Future<int> getLastIndex({
    required Blockchain blockchain,
    required Exposure exposure,
    DerivationWallet? derivationWallet,
  }) async {
    derivationWallet ??= cubits.keys.master.derivationWallets.last;
    final index = await cubits.receive.getIndex(
      blockchain: blockchain,
      exposure: exposure,
      derivationWallet: derivationWallet,
    );
    return index;
  }

  String getPrivateKeyOf({
    required Blockchain blockchain,
    required Exposure exposure,
    required DerivationWallet derivationWallet,
    required int hdIndex,
  }) {
    return derivationWallet
        .seedWallet(blockchain)
        .subwallet(
          hdIndex: hdIndex,
          exposure: exposure,
        )
        .keyPair
        .toWIF();
  }

  Future<List<String>> findSatoriBalanceWIFs(
    List<String> satoriAddresses,
  ) async {
    List<DerivationWallet> derivationWallets =
        cubits.keys.master.derivationWallets;
    List<KeypairWallet> keypairWallets = cubits.keys.master.keypairWallets;
    List<String> wifs = [];

    if (derivationWallets.isNotEmpty) {
      for (var derivationWallet in derivationWallets) {
        for (var seedWallet in derivationWallet.seedWallets.values) {
          for (var subWalletList in List.of(seedWallet.subwallets.values)) {
            for (var subWallet in List.of(subWalletList)) {
              if (satoriAddresses.contains(subWallet.address)) {
                String privateKey = derivationWallet
                    .seedWallet((subWallet as HDWalletIndexed).blockchain)
                    .subwallet(
                      hdIndex: subWallet.hdIndex,
                      exposure: subWallet.exposure,
                    )
                    .keyPair
                    .toWIF();

                wifs.add(privateKey);
              }
            }
          }
        }
      }
    }
    if (keypairWallets.isNotEmpty) {
      for (var keypairWallet in cubits.keys.master.keypairWallets) {
        for (var kpWallet in keypairWallet.wallets.values) {
          if (satoriAddresses.contains(kpWallet.address)) {
            wifs.add(keypairWallet.wif);
            logWTF(
              'Keypair Wallet Address: ${kpWallet.address}\nPrivate Key: '
              '${keypairWallet.wif}',
            );
          }
        }
      }
    }

    wifs = wifs.toSet().toList();

    logI('Total WIFs found (unique): ${wifs.length}');
    return wifs;
  }

  Future<List<String>> findAllWalletAddresses() async {
    List<DerivationWallet> derivationWallets =
        cubits.keys.master.derivationWallets;
    List<KeypairWallet> keypairWallets = cubits.keys.master.keypairWallets;

    List<String> allAddresses = [];

    if (derivationWallets.isNotEmpty) {
      for (var derivationWallet in derivationWallets) {
        for (var seedWallet in derivationWallet.seedWallets.values) {
          if (seedWallet.blockchain == Blockchain.evrmoreMain) {
            for (var subWalletList in List.of(seedWallet.subwallets.values)) {
              for (var subWallet in List.of(subWalletList)) {
                if (subWallet.address != null) {
                  allAddresses.add(subWallet.address!);
                }
              }
            }
          }
        }
      }
    }

    if (keypairWallets.isNotEmpty) {
      for (var keypairWallet in keypairWallets) {
        for (var kpWallet in keypairWallet.wallets.values) {
          if (kpWallet.address != null &&
              kpWallet.address!.toLowerCase().startsWith('e')) {
            allAddresses.add(kpWallet.address!);
          }
        }
      }
    }

    allAddresses = allAddresses.toSet().toList();
    logI('Total unique addresses found: ${allAddresses.length}');
    return allAddresses;
  }

  Future<void> joinPool() async {
    try {
      await _fadeOutAndIn();
      //Todo: remove when fix screen freeze issue
      await Future.delayed(const Duration(milliseconds: 150));
      //await Future.delayed(const Duration(milliseconds: 500));

      // var satoriData = state.balanceAddresses?.firstWhereOrNull(
      //   (element) => element.symbol.toLowerCase() == 'satori',
      // );
      //
      // if (satoriData == null || satoriData.addresses.isEmpty) {
      //   logE('Satori data not found');
      //   update(isSubmitting: false);
      //   return;
      // }

      List<String> satoriAddresses = await findAllWalletAddresses();
      print('satoriAddresses: $satoriAddresses');
      final privateKeys = await findSatoriBalanceWIFs(satoriAddresses);
      print('privateKeys: $privateKeys');

      if (privateKeys.isEmpty) {
        logE('No WIFs found');
        print('No WIFs found');
        update(isSubmitting: false);
        return;
      }

      List<KPWallet> kpWallets = privateKeys.map((wif) {
        return KPWallet.fromWIF(wif, Blockchain.evrmoreMain.network);
      }).toList();
      print('kpWallets: $kpWallets');

      SatoriServerClient satoriClient = SatoriServerClient();
      print('satoriClient: $satoriClient');

      const int batchSize = 10;
      bool allRegistered = true;

      print('satoriAddresses.first: ${satoriAddresses.first}');
      for (int i = 0; i < kpWallets.length; i += batchSize) {
        final batch = kpWallets.skip(i).take(batchSize).toList();
        print('batch len: ${batch.length}');

        bool batchRegistered = await Future.wait(batch.map((kpWallet) async {
          return await satoriClient.registerWallet(
            kpWallet: kpWallet,
            rewardAddress: satoriAddresses.first,
          );
        })).then((results) => results.every((result) => result));
        print('batchRegistered: $batchRegistered');

        bool batchJoinedPool = await Future.wait(batch.map((kpWallet) async {
          return await satoriClient.lendStakeToAddress(kpWallet: kpWallet);
        })).then((results) => results.every((result) => result));
        print('batchJoinedPool: $batchJoinedPool');

        //if (!batchRegistered && !batchJoinedPool) {
        //  // its ok if some file to register - they might already be registered
        //  allRegistered = false;
        //  break;
        //}
      }

      //if (!allRegistered) {
      //  update(isSubmitting: false);
      //  return;
      //}

      // verify we have joined the pool
      final rewardAddresses = await satoriClient.getRewardAddresses(
        addresses: [satoriAddresses.first],
      );
      print('rewardAddresses: $rewardAddresses');
      if (rewardAddresses.isNotEmpty &&
          rewardAddresses.containsValue(satoriAddresses.first)) {
        print('in if');
        await secureStorage.write(
          key: SecureStorageKey.poolAddress.key(),
          value: rewardAddresses.values.first,
        );
        print('wrote');
        Holding satoriHolding = cubits.holding.state.holding;
        print('satoriHolding: $satoriHolding');
        if (satoriHolding.sats.value > 0) {
          print('satoriHolding: $satoriHolding');
          cubits.pool.update(
            poolAddress: satoriAddresses.first,
            poolStatus: PoolStatus.joined,
            pooHolding: satoriHolding,
          );
        }
        cubits.fade.update(fade: FadeEvent.fadeIn);
        update(isSubmitting: false, poolStatus: PoolStatus.joined);
        cubits.toast.flash(
          msg: const ToastMessage(
            title: 'Success!',
            text: 'Magic Pool Joined',
          ),
        );
      } else {
        logE('Failed to join the pool');
        cubits.toast.flash(
          msg: const ToastMessage(
            title: '',
            text: 'Failed to join the pool',
          ),
        );
        update(isSubmitting: false);
      }
    } catch (e, st) {
      logE('Error during join pool: $e $st');
      cubits.toast.flash(
        msg: const ToastMessage(
          title: '',
          text: 'Failed to join the pool',
        ),
      );
      update(isSubmitting: false);
    }
  }

  Future<void> leavePool() async {
    try {
      await _fadeOutAndIn();

      //Todo: remove when fix screen freeze issue
      await Future.delayed(const Duration(milliseconds: 150));

      List<String> satoriAddresses = await findAllWalletAddresses();
      final privateKeys = await findSatoriBalanceWIFs(satoriAddresses);

      if (privateKeys.isEmpty) {
        logE('No WIFs found');
        update(isSubmitting: false);
        return;
      }

      List<KPWallet> kpWallets = privateKeys.map((wif) {
        return KPWallet.fromWIF(wif, Blockchain.evrmoreMain.network);
      }).toList();

      SatoriServerClient satoriClient = SatoriServerClient();

      const int batchSize = 10;
      bool allLeft = true;

      for (int i = 0; i < kpWallets.length; i += batchSize) {
        final batch = kpWallets.skip(i).take(batchSize).toList();

        bool batchLeavePool = await Future.wait(batch.map((kpWallet) async {
          return await satoriClient.removeLentStake(kpWallet: kpWallet);
        })).then((results) => results.every((result) => result));

        if (!batchLeavePool) {
          allLeft = false;
          break;
        }
      }

      /// if there's an issue we don't necessarily have to stop short.
      /// TODO: explore what to do here
      //if (!allLeft) {
      //  update(isSubmitting: false);
      //  return;
      //}

      await secureStorage.write(
        key: SecureStorageKey.poolAddress.key(),
        value: '',
      );

      update(
        isSubmitting: false,
        poolAddress: '',
        pooHolding: Holding.empty(),
        poolStatus: PoolStatus.notJoined,
      );
      cubits.fade.update(fade: FadeEvent.fadeIn);
    } catch (e, st) {
      logE('$e $st');
      cubits.toast.flash(
        msg: const ToastMessage(
          title: 'Error',
          text: 'Some error occurred',
        ),
      );
      update(isSubmitting: false);
    }
    cubits.toast.flash(
      msg: const ToastMessage(
        title: 'Success!',
        text: 'Exited Magic Pool',
      ),
    );
  }

  Future<void> registerAddressOnSatoriTransaction({
    required List<String> addresses,
  }) async {
    var poolAddress =
        await secureStorage.read(key: SecureStorageKey.poolAddress.key());
    final privateKeys = await findSatoriBalanceWIFs(addresses);

    if (privateKeys.isEmpty || poolAddress == null || poolAddress.isEmpty) {
      logE('No WIFs found or pool address not found');
      return;
    }

    List<KPWallet> kpWallets = privateKeys.map((wif) {
      return KPWallet.fromWIF(wif, Blockchain.evrmoreMain.network);
    }).toList();

    // var satoriData = state.balanceAddresses?.firstWhereOrNull(
    //   (element) => element.symbol.toLowerCase() == 'satori',
    // );
    //
    // if (satoriData == null || satoriData.addresses.isEmpty) {
    //   logE('Satori data not found');
    //   update(isSubmitting: false);
    //   return;
    // }

    SatoriServerClient satoriClient = SatoriServerClient();

    // TODO: only register the addresses that need to be.
    bool allRegistered = await Future.wait(kpWallets.map((kpWallet) async {
      return await satoriClient.registerWallet(
        kpWallet: kpWallet,
        rewardAddress: poolAddress,
      );
    })).then((results) => results.every((result) => result));

    bool allJoinedPool = await Future.wait(kpWallets.map((kpWallet) async {
      return await satoriClient.lendStakeToAddress(kpWallet: kpWallet);
    })).then((results) => results.every((result) => result));

    if (!allRegistered && !allJoinedPool) {
      return;
    }

    Holding satoriHolding = cubits.wallet.state.holdings.firstWhere(
      (element) => element.symbol == 'SATORI',
      orElse: () => Holding.empty(),
    );
    if (satoriHolding.sats.value > 0) {
      update(
        pooHolding: satoriHolding,
      );
    }
  }

  Future<void> _fadeOutAndIn() async {
    cubits.fade.update(fade: FadeEvent.fadeOut);
    await Future.delayed(fadeDuration);
    update(isSubmitting: true);
    cubits.fade.update(fade: FadeEvent.fadeIn);
  }
}
