/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

library protocol; // ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'asset_class.dart' as _i2;
import 'asset_metadata_class.dart' as _i3;
import 'asset_metadata_history_class.dart' as _i4;
import 'block_class.dart' as _i5;
import 'chain_class.dart' as _i6;
import 'comm_asset_create.dart' as _i7;
import 'comm_asset_global_freeze.dart' as _i8;
import 'comm_asset_reissue.dart' as _i9;
import 'comm_asset_tag_address.dart' as _i10;
import 'comm_balance_view.dart' as _i11;
import 'comm_bool.dart' as _i12;
import 'comm_error_class.dart' as _i13;
import 'comm_int.dart' as _i14;
import 'comm_notify_h160_balance.dart' as _i15;
import 'comm_notify_height.dart' as _i16;
import 'comm_notify_status.dart' as _i17;
import 'comm_notify_wallet_balance.dart' as _i18;
import 'comm_ps_transaction_request_class.dart' as _i19;
import 'comm_string.dart' as _i20;
import 'comm_subscribe.dart' as _i21;
import 'comm_transaction_details_view.dart' as _i22;
import 'comm_transaction_view.dart' as _i23;
import 'comm_unsigned_transaction_request_class.dart' as _i24;
import 'comm_unsigned_transaction_result_class.dart' as _i25;
import 'consent_class.dart' as _i26;
import 'consent_document_class.dart' as _i27;
import 'h160_balance_current_class.dart' as _i28;
import 'h160_balance_incremental_class.dart' as _i29;
import 'h160_class.dart' as _i30;
import 'restricted_h160_freeze_link_class.dart' as _i31;
import 'restricted_h160_freeze_link_history_class.dart' as _i32;
import 'restricted_h160_qualification_history_class.dart' as _i33;
import 'restricted_h160_qualification_link_class.dart' as _i34;
import 'transaction_asset_link.dart' as _i35;
import 'transaction_class.dart' as _i36;
import 'vout_class.dart' as _i37;
import 'wallet_balance_current_class.dart' as _i38;
import 'wallet_balance_incremental_class.dart' as _i39;
import 'wallet_chain_link.dart' as _i40;
import 'wallet_class.dart' as _i41;
import 'package:client_back/server/src/protocol/asset_metadata_class.dart'
    as _i42;
import 'package:client_back/server/src/protocol/comm_balance_view.dart' as _i43;
import 'dart:typed_data' as _i44;
import 'package:client_back/server/src/protocol/comm_transaction_view.dart'
    as _i45;
import 'package:client_back/server/src/protocol/comm_unsigned_transaction_result_class.dart'
    as _i46;
export 'asset_class.dart';
export 'asset_metadata_class.dart';
export 'asset_metadata_history_class.dart';
export 'block_class.dart';
export 'chain_class.dart';
export 'comm_asset_create.dart';
export 'comm_asset_global_freeze.dart';
export 'comm_asset_reissue.dart';
export 'comm_asset_tag_address.dart';
export 'comm_balance_view.dart';
export 'comm_bool.dart';
export 'comm_error_class.dart';
export 'comm_int.dart';
export 'comm_notify_h160_balance.dart';
export 'comm_notify_height.dart';
export 'comm_notify_status.dart';
export 'comm_notify_wallet_balance.dart';
export 'comm_ps_transaction_request_class.dart';
export 'comm_string.dart';
export 'comm_subscribe.dart';
export 'comm_transaction_details_view.dart';
export 'comm_transaction_view.dart';
export 'comm_unsigned_transaction_request_class.dart';
export 'comm_unsigned_transaction_result_class.dart';
export 'consent_class.dart';
export 'consent_document_class.dart';
export 'h160_balance_current_class.dart';
export 'h160_balance_incremental_class.dart';
export 'h160_class.dart';
export 'restricted_h160_freeze_link_class.dart';
export 'restricted_h160_freeze_link_history_class.dart';
export 'restricted_h160_qualification_history_class.dart';
export 'restricted_h160_qualification_link_class.dart';
export 'transaction_asset_link.dart';
export 'transaction_class.dart';
export 'vout_class.dart';
export 'wallet_balance_current_class.dart';
export 'wallet_balance_incremental_class.dart';
export 'wallet_chain_link.dart';
export 'wallet_class.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Map<Type, _i1.constructor> customConstructors = {};

  static final Protocol _instance = Protocol._();

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;
    if (customConstructors.containsKey(t)) {
      return customConstructors[t]!(data, this) as T;
    }
    if (t == _i2.Asset) {
      return _i2.Asset.fromJson(data, this) as T;
    }
    if (t == _i3.AssetMetadata) {
      return _i3.AssetMetadata.fromJson(data, this) as T;
    }
    if (t == _i4.AssetMetadataHistory) {
      return _i4.AssetMetadataHistory.fromJson(data, this) as T;
    }
    if (t == _i5.BlockchainBlock) {
      return _i5.BlockchainBlock.fromJson(data, this) as T;
    }
    if (t == _i6.Chain) {
      return _i6.Chain.fromJson(data, this) as T;
    }
    if (t == _i7.AssetCreationRequest) {
      return _i7.AssetCreationRequest.fromJson(data, this) as T;
    }
    if (t == _i8.AssetGlobalFreezeRequest) {
      return _i8.AssetGlobalFreezeRequest.fromJson(data, this) as T;
    }
    if (t == _i9.AssetReissueRequest) {
      return _i9.AssetReissueRequest.fromJson(data, this) as T;
    }
    if (t == _i10.AssetAddressTagRequest) {
      return _i10.AssetAddressTagRequest.fromJson(data, this) as T;
    }
    if (t == _i11.BalanceView) {
      return _i11.BalanceView.fromJson(data, this) as T;
    }
    if (t == _i12.CommBool) {
      return _i12.CommBool.fromJson(data, this) as T;
    }
    if (t == _i13.EndpointError) {
      return _i13.EndpointError.fromJson(data, this) as T;
    }
    if (t == _i14.CommInt) {
      return _i14.CommInt.fromJson(data, this) as T;
    }
    if (t == _i15.NotifyChainH160Balance) {
      return _i15.NotifyChainH160Balance.fromJson(data, this) as T;
    }
    if (t == _i16.NotifyChainHeight) {
      return _i16.NotifyChainHeight.fromJson(data, this) as T;
    }
    if (t == _i17.NotifyChainStatus) {
      return _i17.NotifyChainStatus.fromJson(data, this) as T;
    }
    if (t == _i18.NotifyChainWalletBalance) {
      return _i18.NotifyChainWalletBalance.fromJson(data, this) as T;
    }
    if (t == _i19.PartiallySignedTransactionRequest) {
      return _i19.PartiallySignedTransactionRequest.fromJson(data, this) as T;
    }
    if (t == _i20.CommString) {
      return _i20.CommString.fromJson(data, this) as T;
    }
    if (t == _i21.ChainWalletH160Subscription) {
      return _i21.ChainWalletH160Subscription.fromJson(data, this) as T;
    }
    if (t == _i22.TransactionDetailsView) {
      return _i22.TransactionDetailsView.fromJson(data, this) as T;
    }
    if (t == _i23.TransactionView) {
      return _i23.TransactionView.fromJson(data, this) as T;
    }
    if (t == _i24.UnsignedTransactionRequest) {
      return _i24.UnsignedTransactionRequest.fromJson(data, this) as T;
    }
    if (t == _i25.UnsignedTransactionResult) {
      return _i25.UnsignedTransactionResult.fromJson(data, this) as T;
    }
    if (t == _i26.Consent) {
      return _i26.Consent.fromJson(data, this) as T;
    }
    if (t == _i27.ConsentDocument) {
      return _i27.ConsentDocument.fromJson(data, this) as T;
    }
    if (t == _i28.AddressBalanceCurrent) {
      return _i28.AddressBalanceCurrent.fromJson(data, this) as T;
    }
    if (t == _i29.AddressBalanceIncremental) {
      return _i29.AddressBalanceIncremental.fromJson(data, this) as T;
    }
    if (t == _i30.H160) {
      return _i30.H160.fromJson(data, this) as T;
    }
    if (t == _i31.RestrictedH160FreezeLink) {
      return _i31.RestrictedH160FreezeLink.fromJson(data, this) as T;
    }
    if (t == _i32.RestrictedH160FreezeLinkHistory) {
      return _i32.RestrictedH160FreezeLinkHistory.fromJson(data, this) as T;
    }
    if (t == _i33.RestrictedH160QualificationLinkHistory) {
      return _i33.RestrictedH160QualificationLinkHistory.fromJson(data, this)
          as T;
    }
    if (t == _i34.RestrictedH160QualificationLink) {
      return _i34.RestrictedH160QualificationLink.fromJson(data, this) as T;
    }
    if (t == _i35.TransctionAssetLink) {
      return _i35.TransctionAssetLink.fromJson(data, this) as T;
    }
    if (t == _i36.BlockchainTransaction) {
      return _i36.BlockchainTransaction.fromJson(data, this) as T;
    }
    if (t == _i37.Vout) {
      return _i37.Vout.fromJson(data, this) as T;
    }
    if (t == _i38.WalletBalanceCurrent) {
      return _i38.WalletBalanceCurrent.fromJson(data, this) as T;
    }
    if (t == _i39.WalletBalanceIncremental) {
      return _i39.WalletBalanceIncremental.fromJson(data, this) as T;
    }
    if (t == _i40.WalletChainLink) {
      return _i40.WalletChainLink.fromJson(data, this) as T;
    }
    if (t == _i41.Wallet) {
      return _i41.Wallet.fromJson(data, this) as T;
    }
    if (t == _i1.getType<_i2.Asset?>()) {
      return (data != null ? _i2.Asset.fromJson(data, this) : null) as T;
    }
    if (t == _i1.getType<_i3.AssetMetadata?>()) {
      return (data != null ? _i3.AssetMetadata.fromJson(data, this) : null)
          as T;
    }
    if (t == _i1.getType<_i4.AssetMetadataHistory?>()) {
      return (data != null
          ? _i4.AssetMetadataHistory.fromJson(data, this)
          : null) as T;
    }
    if (t == _i1.getType<_i5.BlockchainBlock?>()) {
      return (data != null ? _i5.BlockchainBlock.fromJson(data, this) : null)
          as T;
    }
    if (t == _i1.getType<_i6.Chain?>()) {
      return (data != null ? _i6.Chain.fromJson(data, this) : null) as T;
    }
    if (t == _i1.getType<_i7.AssetCreationRequest?>()) {
      return (data != null
          ? _i7.AssetCreationRequest.fromJson(data, this)
          : null) as T;
    }
    if (t == _i1.getType<_i8.AssetGlobalFreezeRequest?>()) {
      return (data != null
          ? _i8.AssetGlobalFreezeRequest.fromJson(data, this)
          : null) as T;
    }
    if (t == _i1.getType<_i9.AssetReissueRequest?>()) {
      return (data != null
          ? _i9.AssetReissueRequest.fromJson(data, this)
          : null) as T;
    }
    if (t == _i1.getType<_i10.AssetAddressTagRequest?>()) {
      return (data != null
          ? _i10.AssetAddressTagRequest.fromJson(data, this)
          : null) as T;
    }
    if (t == _i1.getType<_i11.BalanceView?>()) {
      return (data != null ? _i11.BalanceView.fromJson(data, this) : null) as T;
    }
    if (t == _i1.getType<_i12.CommBool?>()) {
      return (data != null ? _i12.CommBool.fromJson(data, this) : null) as T;
    }
    if (t == _i1.getType<_i13.EndpointError?>()) {
      return (data != null ? _i13.EndpointError.fromJson(data, this) : null)
          as T;
    }
    if (t == _i1.getType<_i14.CommInt?>()) {
      return (data != null ? _i14.CommInt.fromJson(data, this) : null) as T;
    }
    if (t == _i1.getType<_i15.NotifyChainH160Balance?>()) {
      return (data != null
          ? _i15.NotifyChainH160Balance.fromJson(data, this)
          : null) as T;
    }
    if (t == _i1.getType<_i16.NotifyChainHeight?>()) {
      return (data != null ? _i16.NotifyChainHeight.fromJson(data, this) : null)
          as T;
    }
    if (t == _i1.getType<_i17.NotifyChainStatus?>()) {
      return (data != null ? _i17.NotifyChainStatus.fromJson(data, this) : null)
          as T;
    }
    if (t == _i1.getType<_i18.NotifyChainWalletBalance?>()) {
      return (data != null
          ? _i18.NotifyChainWalletBalance.fromJson(data, this)
          : null) as T;
    }
    if (t == _i1.getType<_i19.PartiallySignedTransactionRequest?>()) {
      return (data != null
          ? _i19.PartiallySignedTransactionRequest.fromJson(data, this)
          : null) as T;
    }
    if (t == _i1.getType<_i20.CommString?>()) {
      return (data != null ? _i20.CommString.fromJson(data, this) : null) as T;
    }
    if (t == _i1.getType<_i21.ChainWalletH160Subscription?>()) {
      return (data != null
          ? _i21.ChainWalletH160Subscription.fromJson(data, this)
          : null) as T;
    }
    if (t == _i1.getType<_i22.TransactionDetailsView?>()) {
      return (data != null
          ? _i22.TransactionDetailsView.fromJson(data, this)
          : null) as T;
    }
    if (t == _i1.getType<_i23.TransactionView?>()) {
      return (data != null ? _i23.TransactionView.fromJson(data, this) : null)
          as T;
    }
    if (t == _i1.getType<_i24.UnsignedTransactionRequest?>()) {
      return (data != null
          ? _i24.UnsignedTransactionRequest.fromJson(data, this)
          : null) as T;
    }
    if (t == _i1.getType<_i25.UnsignedTransactionResult?>()) {
      return (data != null
          ? _i25.UnsignedTransactionResult.fromJson(data, this)
          : null) as T;
    }
    if (t == _i1.getType<_i26.Consent?>()) {
      return (data != null ? _i26.Consent.fromJson(data, this) : null) as T;
    }
    if (t == _i1.getType<_i27.ConsentDocument?>()) {
      return (data != null ? _i27.ConsentDocument.fromJson(data, this) : null)
          as T;
    }
    if (t == _i1.getType<_i28.AddressBalanceCurrent?>()) {
      return (data != null
          ? _i28.AddressBalanceCurrent.fromJson(data, this)
          : null) as T;
    }
    if (t == _i1.getType<_i29.AddressBalanceIncremental?>()) {
      return (data != null
          ? _i29.AddressBalanceIncremental.fromJson(data, this)
          : null) as T;
    }
    if (t == _i1.getType<_i30.H160?>()) {
      return (data != null ? _i30.H160.fromJson(data, this) : null) as T;
    }
    if (t == _i1.getType<_i31.RestrictedH160FreezeLink?>()) {
      return (data != null
          ? _i31.RestrictedH160FreezeLink.fromJson(data, this)
          : null) as T;
    }
    if (t == _i1.getType<_i32.RestrictedH160FreezeLinkHistory?>()) {
      return (data != null
          ? _i32.RestrictedH160FreezeLinkHistory.fromJson(data, this)
          : null) as T;
    }
    if (t == _i1.getType<_i33.RestrictedH160QualificationLinkHistory?>()) {
      return (data != null
          ? _i33.RestrictedH160QualificationLinkHistory.fromJson(data, this)
          : null) as T;
    }
    if (t == _i1.getType<_i34.RestrictedH160QualificationLink?>()) {
      return (data != null
          ? _i34.RestrictedH160QualificationLink.fromJson(data, this)
          : null) as T;
    }
    if (t == _i1.getType<_i35.TransctionAssetLink?>()) {
      return (data != null
          ? _i35.TransctionAssetLink.fromJson(data, this)
          : null) as T;
    }
    if (t == _i1.getType<_i36.BlockchainTransaction?>()) {
      return (data != null
          ? _i36.BlockchainTransaction.fromJson(data, this)
          : null) as T;
    }
    if (t == _i1.getType<_i37.Vout?>()) {
      return (data != null ? _i37.Vout.fromJson(data, this) : null) as T;
    }
    if (t == _i1.getType<_i38.WalletBalanceCurrent?>()) {
      return (data != null
          ? _i38.WalletBalanceCurrent.fromJson(data, this)
          : null) as T;
    }
    if (t == _i1.getType<_i39.WalletBalanceIncremental?>()) {
      return (data != null
          ? _i39.WalletBalanceIncremental.fromJson(data, this)
          : null) as T;
    }
    if (t == _i1.getType<_i40.WalletChainLink?>()) {
      return (data != null ? _i40.WalletChainLink.fromJson(data, this) : null)
          as T;
    }
    if (t == _i1.getType<_i41.Wallet?>()) {
      return (data != null ? _i41.Wallet.fromJson(data, this) : null) as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList()
          as dynamic;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
          ? (data as List).map((e) => deserialize<String>(e)).toList()
          : null) as dynamic;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
          ? (data as List).map((e) => deserialize<String>(e)).toList()
          : null) as dynamic;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
          ? (data as List).map((e) => deserialize<String>(e)).toList()
          : null) as dynamic;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
          ? (data as List).map((e) => deserialize<String>(e)).toList()
          : null) as dynamic;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
          ? (data as List).map((e) => deserialize<String>(e)).toList()
          : null) as dynamic;
    }
    if (t == List<String?>) {
      return (data as List).map((e) => deserialize<String?>(e)).toList()
          as dynamic;
    }
    if (t == List<int>) {
      return (data as List).map((e) => deserialize<int>(e)).toList() as dynamic;
    }
    if (t == List<int?>) {
      return (data as List).map((e) => deserialize<int?>(e)).toList()
          as dynamic;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
          ? (data as List).map((e) => deserialize<String>(e)).toList()
          : null) as dynamic;
    }
    if (t == List<_i42.AssetMetadata>) {
      return (data as List)
          .map((e) => deserialize<_i42.AssetMetadata>(e))
          .toList() as dynamic;
    }
    if (t == List<_i43.BalanceView>) {
      return (data as List)
          .map((e) => deserialize<_i43.BalanceView>(e))
          .toList() as dynamic;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList()
          as dynamic;
    }
    if (t == List<_i44.ByteData>) {
      return (data as List).map((e) => deserialize<_i44.ByteData>(e)).toList()
          as dynamic;
    }
    if (t == List<_i45.TransactionView>) {
      return (data as List)
          .map((e) => deserialize<_i45.TransactionView>(e))
          .toList() as dynamic;
    }
    if (t == List<_i46.UnsignedTransactionResult>) {
      return (data as List)
          .map((e) => deserialize<_i46.UnsignedTransactionResult>(e))
          .toList() as dynamic;
    }
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object data) {
    if (data is _i2.Asset) {
      return 'Asset';
    }
    if (data is _i3.AssetMetadata) {
      return 'AssetMetadata';
    }
    if (data is _i4.AssetMetadataHistory) {
      return 'AssetMetadataHistory';
    }
    if (data is _i5.BlockchainBlock) {
      return 'BlockchainBlock';
    }
    if (data is _i6.Chain) {
      return 'Chain';
    }
    if (data is _i7.AssetCreationRequest) {
      return 'AssetCreationRequest';
    }
    if (data is _i8.AssetGlobalFreezeRequest) {
      return 'AssetGlobalFreezeRequest';
    }
    if (data is _i9.AssetReissueRequest) {
      return 'AssetReissueRequest';
    }
    if (data is _i10.AssetAddressTagRequest) {
      return 'AssetAddressTagRequest';
    }
    if (data is _i11.BalanceView) {
      return 'BalanceView';
    }
    if (data is _i12.CommBool) {
      return 'CommBool';
    }
    if (data is _i13.EndpointError) {
      return 'EndpointError';
    }
    if (data is _i14.CommInt) {
      return 'CommInt';
    }
    if (data is _i15.NotifyChainH160Balance) {
      return 'NotifyChainH160Balance';
    }
    if (data is _i16.NotifyChainHeight) {
      return 'NotifyChainHeight';
    }
    if (data is _i17.NotifyChainStatus) {
      return 'NotifyChainStatus';
    }
    if (data is _i18.NotifyChainWalletBalance) {
      return 'NotifyChainWalletBalance';
    }
    if (data is _i19.PartiallySignedTransactionRequest) {
      return 'PartiallySignedTransactionRequest';
    }
    if (data is _i20.CommString) {
      return 'CommString';
    }
    if (data is _i21.ChainWalletH160Subscription) {
      return 'ChainWalletH160Subscription';
    }
    if (data is _i22.TransactionDetailsView) {
      return 'TransactionDetailsView';
    }
    if (data is _i23.TransactionView) {
      return 'TransactionView';
    }
    if (data is _i24.UnsignedTransactionRequest) {
      return 'UnsignedTransactionRequest';
    }
    if (data is _i25.UnsignedTransactionResult) {
      return 'UnsignedTransactionResult';
    }
    if (data is _i26.Consent) {
      return 'Consent';
    }
    if (data is _i27.ConsentDocument) {
      return 'ConsentDocument';
    }
    if (data is _i28.AddressBalanceCurrent) {
      return 'AddressBalanceCurrent';
    }
    if (data is _i29.AddressBalanceIncremental) {
      return 'AddressBalanceIncremental';
    }
    if (data is _i30.H160) {
      return 'H160';
    }
    if (data is _i31.RestrictedH160FreezeLink) {
      return 'RestrictedH160FreezeLink';
    }
    if (data is _i32.RestrictedH160FreezeLinkHistory) {
      return 'RestrictedH160FreezeLinkHistory';
    }
    if (data is _i33.RestrictedH160QualificationLinkHistory) {
      return 'RestrictedH160QualificationLinkHistory';
    }
    if (data is _i34.RestrictedH160QualificationLink) {
      return 'RestrictedH160QualificationLink';
    }
    if (data is _i35.TransctionAssetLink) {
      return 'TransctionAssetLink';
    }
    if (data is _i36.BlockchainTransaction) {
      return 'BlockchainTransaction';
    }
    if (data is _i37.Vout) {
      return 'Vout';
    }
    if (data is _i38.WalletBalanceCurrent) {
      return 'WalletBalanceCurrent';
    }
    if (data is _i39.WalletBalanceIncremental) {
      return 'WalletBalanceIncremental';
    }
    if (data is _i40.WalletChainLink) {
      return 'WalletChainLink';
    }
    if (data is _i41.Wallet) {
      return 'Wallet';
    }
    return super.getClassNameForObject(data);
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    if (data['className'] == 'Asset') {
      return deserialize<_i2.Asset>(data['data']);
    }
    if (data['className'] == 'AssetMetadata') {
      return deserialize<_i3.AssetMetadata>(data['data']);
    }
    if (data['className'] == 'AssetMetadataHistory') {
      return deserialize<_i4.AssetMetadataHistory>(data['data']);
    }
    if (data['className'] == 'BlockchainBlock') {
      return deserialize<_i5.BlockchainBlock>(data['data']);
    }
    if (data['className'] == 'Chain') {
      return deserialize<_i6.Chain>(data['data']);
    }
    if (data['className'] == 'AssetCreationRequest') {
      return deserialize<_i7.AssetCreationRequest>(data['data']);
    }
    if (data['className'] == 'AssetGlobalFreezeRequest') {
      return deserialize<_i8.AssetGlobalFreezeRequest>(data['data']);
    }
    if (data['className'] == 'AssetReissueRequest') {
      return deserialize<_i9.AssetReissueRequest>(data['data']);
    }
    if (data['className'] == 'AssetAddressTagRequest') {
      return deserialize<_i10.AssetAddressTagRequest>(data['data']);
    }
    if (data['className'] == 'BalanceView') {
      return deserialize<_i11.BalanceView>(data['data']);
    }
    if (data['className'] == 'CommBool') {
      return deserialize<_i12.CommBool>(data['data']);
    }
    if (data['className'] == 'EndpointError') {
      return deserialize<_i13.EndpointError>(data['data']);
    }
    if (data['className'] == 'CommInt') {
      return deserialize<_i14.CommInt>(data['data']);
    }
    if (data['className'] == 'NotifyChainH160Balance') {
      return deserialize<_i15.NotifyChainH160Balance>(data['data']);
    }
    if (data['className'] == 'NotifyChainHeight') {
      return deserialize<_i16.NotifyChainHeight>(data['data']);
    }
    if (data['className'] == 'NotifyChainStatus') {
      return deserialize<_i17.NotifyChainStatus>(data['data']);
    }
    if (data['className'] == 'NotifyChainWalletBalance') {
      return deserialize<_i18.NotifyChainWalletBalance>(data['data']);
    }
    if (data['className'] == 'PartiallySignedTransactionRequest') {
      return deserialize<_i19.PartiallySignedTransactionRequest>(data['data']);
    }
    if (data['className'] == 'CommString') {
      return deserialize<_i20.CommString>(data['data']);
    }
    if (data['className'] == 'ChainWalletH160Subscription') {
      return deserialize<_i21.ChainWalletH160Subscription>(data['data']);
    }
    if (data['className'] == 'TransactionDetailsView') {
      return deserialize<_i22.TransactionDetailsView>(data['data']);
    }
    if (data['className'] == 'TransactionView') {
      return deserialize<_i23.TransactionView>(data['data']);
    }
    if (data['className'] == 'UnsignedTransactionRequest') {
      return deserialize<_i24.UnsignedTransactionRequest>(data['data']);
    }
    if (data['className'] == 'UnsignedTransactionResult') {
      return deserialize<_i25.UnsignedTransactionResult>(data['data']);
    }
    if (data['className'] == 'Consent') {
      return deserialize<_i26.Consent>(data['data']);
    }
    if (data['className'] == 'ConsentDocument') {
      return deserialize<_i27.ConsentDocument>(data['data']);
    }
    if (data['className'] == 'AddressBalanceCurrent') {
      return deserialize<_i28.AddressBalanceCurrent>(data['data']);
    }
    if (data['className'] == 'AddressBalanceIncremental') {
      return deserialize<_i29.AddressBalanceIncremental>(data['data']);
    }
    if (data['className'] == 'H160') {
      return deserialize<_i30.H160>(data['data']);
    }
    if (data['className'] == 'RestrictedH160FreezeLink') {
      return deserialize<_i31.RestrictedH160FreezeLink>(data['data']);
    }
    if (data['className'] == 'RestrictedH160FreezeLinkHistory') {
      return deserialize<_i32.RestrictedH160FreezeLinkHistory>(data['data']);
    }
    if (data['className'] == 'RestrictedH160QualificationLinkHistory') {
      return deserialize<_i33.RestrictedH160QualificationLinkHistory>(
          data['data']);
    }
    if (data['className'] == 'RestrictedH160QualificationLink') {
      return deserialize<_i34.RestrictedH160QualificationLink>(data['data']);
    }
    if (data['className'] == 'TransctionAssetLink') {
      return deserialize<_i35.TransctionAssetLink>(data['data']);
    }
    if (data['className'] == 'BlockchainTransaction') {
      return deserialize<_i36.BlockchainTransaction>(data['data']);
    }
    if (data['className'] == 'Vout') {
      return deserialize<_i37.Vout>(data['data']);
    }
    if (data['className'] == 'WalletBalanceCurrent') {
      return deserialize<_i38.WalletBalanceCurrent>(data['data']);
    }
    if (data['className'] == 'WalletBalanceIncremental') {
      return deserialize<_i39.WalletBalanceIncremental>(data['data']);
    }
    if (data['className'] == 'WalletChainLink') {
      return deserialize<_i40.WalletChainLink>(data['data']);
    }
    if (data['className'] == 'Wallet') {
      return deserialize<_i41.Wallet>(data['data']);
    }
    return super.deserializeByClassName(data);
  }
}
