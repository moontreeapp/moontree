/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'dart:async' as _i2;
import 'comm_balance_view.dart' as _i3;
import 'dart:typed_data' as _i4;
import 'comm_transaction_view.dart' as _i5;
import 'dart:io' as _i6;
import 'protocol.dart' as _i7;

class _EndpointBalances extends _i1.EndpointRef {
  _EndpointBalances(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'balances';

  _i2.Future<List<_i3.BalanceView>> get({
    required String chain,
    required List<String> xpubkeys,
    required List<_i4.ByteData> h160s,
  }) =>
      caller.callServerEndpoint<List<_i3.BalanceView>>(
        'balances',
        'get',
        {
          'chain': chain,
          'xpubkeys': xpubkeys,
          'h160s': h160s,
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

class _EndpointTransactions extends _i1.EndpointRef {
  _EndpointTransactions(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'transactions';

  _i2.Future<List<_i5.TransactionView>> get({
    String? symbol,
    required String chain,
    required List<String> xpubkeys,
    required List<_i4.ByteData> h160s,
  }) =>
      caller.callServerEndpoint<List<_i5.TransactionView>>(
        'transactions',
        'get',
        {
          'symbol': symbol,
          'chain': chain,
          'xpubkeys': xpubkeys,
          'h160s': h160s,
        },
      );
}

class Client extends _i1.ServerpodClient {
  Client(
    String host, {
    _i6.SecurityContext? context,
    _i1.AuthenticationKeyManager? authenticationKeyManager,
  }) : super(
          host,
          _i7.Protocol(),
          context: context,
          authenticationKeyManager: authenticationKeyManager,
        ) {
    balances = _EndpointBalances(this);
    example = _EndpointExample(this);
    transactions = _EndpointTransactions(this);
  }

  late final _EndpointBalances balances;

  late final _EndpointExample example;

  late final _EndpointTransactions transactions;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
        'balances': balances,
        'example': example,
        'transactions': transactions,
      };
  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {};
}
