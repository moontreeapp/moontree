import 'package:client_back/server/src/protocol/comm_asset_metadata_response.dart';
import 'package:collection/src/iterable_extensions.dart' show IterableExtension;
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/server/src/protocol/asset_metadata_class.dart';
import 'package:client_back/server/src/protocol/comm_transaction_view.dart';
import 'package:client_front/infrastructure/repos/asset_metadata.dart';
import 'package:client_front/infrastructure/repos/circulating_sats.dart';
import 'package:client_front/application/common.dart';
import 'package:client_front/application/infrastructure/location/cubit.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;

part 'state.dart';

/// show shimmer while retrieving list of transactions
/// show list of transactions
class ManageHoldingViewCubit extends Cubit<ManageHoldingViewState>
    with SetCubitMixin {
  ManageHoldingViewCubit() : super(ManageHoldingViewState.initial()) {
    Future.delayed(Duration(seconds: 10)).then((_) => init());
  }

  @override
  Future<void> reset() async => emit(ManageHoldingViewState.initial());

  @override
  ManageHoldingViewState submitting() => state.load(isSubmitting: true);

  @override
  Future<void> enter() async {
    emit(state);
  }

  @override
  void set({
    AssetMetadataResponse? metadataView,
    Wallet? wallet,
    Security? security,
    Wallet? ranWallet,
    Security? ranSecurity,
    bool? isSubmitting,
  }) {
    emit(state.load(
      metadataView: metadataView,
      wallet: wallet,
      security: security,
      ranWallet: ranWallet,
      ranSecurity: ranSecurity,
      isSubmitting: isSubmitting,
    ));
  }

  void init() {
    components.cubits.location.hooks
        .add((LocationCubitState state, LocationCubitState next) {
      if (state.path == '/wallet/holdings' && next.path == '/wallet/holding') {
        reset();
      }
    });
  }

  /// Here we have logic to avoid populating transactionViews in the event
  /// that we have navigated away from the page in the meantime (cleared the
  /// contents of the cubit)
  bool get cleared => state.ranWallet == null;

  Future<void> setInitial({bool force = false}) async {
    setMetadataView(force: force);
  }

  Future<void> setMetadataView({bool force = false}) async {
    if (force || state.metadataView == null) {
      final checkCleared = state.ranWallet != null;
      submitting();
      final metadataView = (await AssetMetadataHistoryRepo(
        security: state.security,
      ).get());
      if (checkCleared && cleared) {
        return;
      }
      if (state.security.isCoin) {
        metadataView.totalSupply = (await CirculatingSatsRepo(
          security: state.security,
        ).get())
            .value;
      }
      set(
        metadataView: metadataView,
        isSubmitting: false,
      );
    }
  }

  bool get nullCacheView {
    //final Asset? securityAsset = state.security.asset;
    final AssetMetadataResponse? securityAsset = state.metadataView;
    return securityAsset == null;
  }

  void clearCache() => set(
        metadataView: null,
      );
}
