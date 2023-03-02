/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'dart:async' as _i2;
import 'comm_int.dart' as _i3;
import 'asset_metadata_class.dart' as _i4;
import 'comm_balance_view.dart' as _i5;
import 'dart:typed_data' as _i6;
import 'comm_transaction_view.dart' as _i7;
import 'comm_transaction_details_view.dart'
    as _i8;
import 'comm_unsigned_transaction_result_class.dart'
    as _i9;
import 'comm_unsigned_transaction_request_class.dart'
    as _i10;
import 'dart:io' as _i11;
import 'protocol.dart' as _i12;

class _EndpointAddresses extends _i1.EndpointRef {
  _EndpointAddresses(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'addresses';

  _i2.Future<_i3.CommInt> nextEmptyIndex({
    required String chainName,
    required String xpubkey,
  }) =>
      caller.callServerEndpoint<_i3.CommInt>(
        'addresses',
        'nextEmptyIndex',
        {
          'chainName': chainName,
          'xpubkey': xpubkey,
        },
      );
}

class _EndpointMetadata extends _i1.EndpointRef {
  _EndpointMetadata(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'metadata';

  /// generateMetadata returns a empty list or a list with one item in it so why
  /// are we passing a list back here when we could just pass AssetMetadata or
  /// null? Because of the height variable (which is basically ignored at the
  /// moment). In the future we may want to the history of changes of asset
  /// metadata, so we're set up to easily pivot to that scenario. Furthermore,
  /// most the other endpoints return lists so the front end is used to it.
  /// Of course maybe we'd just make a different endpoint for history, but idk.
  _i2.Future<List<_i4.AssetMetadata>> get({
    required String symbol,
    required String chainName,
    int? height,
  }) =>
      caller.callServerEndpoint<List<_i4.AssetMetadata>>(
        'metadata',
        'get',
        {
          'symbol': symbol,
          'chainName': chainName,
          'height': height,
        },
      );
}

class _EndpointBalances extends _i1.EndpointRef {
  _EndpointBalances(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'balances';

  _i2.Future<List<_i5.BalanceView>> get({
    required String chainName,
    required List<String> xpubkeys,
    required List<_i6.ByteData> h160s,
  }) =>
      caller.callServerEndpoint<List<_i5.BalanceView>>(
        'balances',
        'get',
        {
          'chainName': chainName,
          'xpubkeys': xpubkeys,
          'h160s': h160s,
        },
      );
}

class _EndpointConsent extends _i1.EndpointRef {
  _EndpointConsent(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'consent';

  _i2.Future<String> given(
    String deviceId,
    String documentName,
  ) =>
      caller.callServerEndpoint<String>(
        'consent',
        'given',
        {
          'deviceId': deviceId,
          'documentName': documentName,
        },
      );
}

class _EndpointHasGiven extends _i1.EndpointRef {
  _EndpointHasGiven(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'hasGiven';

  _i2.Future<bool> consent(
    String deviceId,
    String documentName,
  ) =>
      caller.callServerEndpoint<bool>(
        'hasGiven',
        'consent',
        {
          'deviceId': deviceId,
          'documentName': documentName,
        },
      );
}

class _EndpointDocument extends _i1.EndpointRef {
  _EndpointDocument(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'document';

  _i2.Future<String> upload(
    String document,
    String documentName,
    String? documentVersion,
  ) =>
      caller.callServerEndpoint<String>(
        'document',
        'upload',
        {
          'document': document,
          'documentName': documentName,
          'documentVersion': documentVersion,
        },
      );
}

class _EndpointExample extends _i1.EndpointRef {
  _EndpointExample(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'example';

  _i2.Future<String> hello(String name) => caller.callServerEndpoint<String>(
        'example',
        'hello',
        {'name': name},
      );
}

class _EndpointMempoolTransactions extends _i1.EndpointRef {
  _EndpointMempoolTransactions(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'mempoolTransactions';

  _i2.Future<List<_i7.TransactionView>> get({
    String? symbol,
    int? backFromHeight,
    required String chainName,
    required List<String> xpubkeys,
    required List<_i6.ByteData> h160s,
  }) =>
      caller.callServerEndpoint<List<_i7.TransactionView>>(
        'mempoolTransactions',
        'get',
        {
          'symbol': symbol,
          'backFromHeight': backFromHeight,
          'chainName': chainName,
          'xpubkeys': xpubkeys,
          'h160s': h160s,
        },
      );
}

class _EndpointSubscription extends _i1.EndpointRef {
  _EndpointSubscription(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'subscription';
}

class _EndpointTransactionDetails extends _i1.EndpointRef {
  _EndpointTransactionDetails(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'transactionDetails';

  _i2.Future<_i8.TransactionDetailsView> get({
    required _i6.ByteData hash,
    required String chainName,
  }) =>
      caller.callServerEndpoint<_i8.TransactionDetailsView>(
        'transactionDetails',
        'get',
        {
          'hash': hash,
          'chainName': chainName,
        },
      );
}

class _EndpointTransactions extends _i1.EndpointRef {
  _EndpointTransactions(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'transactions';

  _i2.Future<List<_i7.TransactionView>> get({
    String? symbol,
    int? backFromHeight,
    required String chainName,
    required List<String> xpubkeys,
    required List<_i6.ByteData> h160s,
  }) =>
      caller.callServerEndpoint<List<_i7.TransactionView>>(
        'transactions',
        'get',
        {
          'symbol': symbol,
          'backFromHeight': backFromHeight,
          'chainName': chainName,
          'xpubkeys': xpubkeys,
          'h160s': h160s,
        },
      );
}

class _EndpointUnsignedTransaction extends _i1.EndpointRef {
  _EndpointUnsignedTransaction(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'unsignedTransaction';

  _i2.Future<_i9.UnsignedTransactionResult> generateUnsignedTransaction({
    required _i10.UnsignedTransactionRequest request,
    required String chainName,
  }) =>
      caller.callServerEndpoint<_i9.UnsignedTransactionResult>(
        'unsignedTransaction',
        'generateUnsignedTransaction',
        {
          'request': request,
          'chainName': chainName,
        },
      );
}

class Client extends _i1.ServerpodClient {
  Client(
    String host, {
    _i11.SecurityContext? context,
    _i1.AuthenticationKeyManager? authenticationKeyManager,
  }) : super(
          host,
          _i12.Protocol(),
          context: context,
          authenticationKeyManager: authenticationKeyManager,
        ) {
    addresses = _EndpointAddresses(this);
    metadata = _EndpointMetadata(this);
    balances = _EndpointBalances(this);
    consent = _EndpointConsent(this);
    hasGiven = _EndpointHasGiven(this);
    document = _EndpointDocument(this);
    example = _EndpointExample(this);
    mempoolTransactions = _EndpointMempoolTransactions(this);
    subscription = _EndpointSubscription(this);
    transactionDetails = _EndpointTransactionDetails(this);
    transactions = _EndpointTransactions(this);
    unsignedTransaction = _EndpointUnsignedTransaction(this);
  }

  late final _EndpointAddresses addresses;

  late final _EndpointMetadata metadata;

  late final _EndpointBalances balances;

  late final _EndpointConsent consent;

  late final _EndpointHasGiven hasGiven;

  late final _EndpointDocument document;

  late final _EndpointExample example;

  late final _EndpointMempoolTransactions mempoolTransactions;

  late final _EndpointSubscription subscription;

  late final _EndpointTransactionDetails transactionDetails;

  late final _EndpointTransactions transactions;

  late final _EndpointUnsignedTransaction unsignedTransaction;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
        'addresses': addresses,
        'metadata': metadata,
        'balances': balances,
        'consent': consent,
        'hasGiven': hasGiven,
        'document': document,
        'example': example,
        'mempoolTransactions': mempoolTransactions,
        'subscription': subscription,
        'transactionDetails': transactionDetails,
        'transactions': transactions,
        'unsignedTransaction': unsignedTransaction,
      };
  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {};
}
