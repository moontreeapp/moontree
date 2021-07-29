import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:raven_electrum_client/methods/get_balance.dart';
import 'package:ravencoin/ravencoin.dart';
import 'package:crypto/crypto.dart' show sha256;
import 'package:convert/convert.dart' show hex;

import 'account.dart';

import '../records/node_exposure.dart';
import '../records/net.dart';
import '../records.dart' as records;

class Address {
  records.Address record;

  Address(scripthash, address, accountId, hdIndex,
      {NodeExposure exposure = NodeExposure.External,
      Net net = Net.Test,
      balance})
      : record = records.Address(scripthash, address, accountId, hdIndex,
            exposure: exposure, net: net, balance: balance);

  String get scripthash => record.scripthash;

  String get address => record.address;

  String get accountId => record.accountId;

  int get hdIndex => record.hdIndex;

  NodeExposure get exposure => record.exposure;

  NetworkType get network => networks[record.net]!;

  ScripthashBalance? get balance => record.balance;

  set balance(ScripthashBalance? bal) => record.balance = bal;

  factory Address.fromRecord(records.Address record) {
    return Address(
        record.scripthash, record.address, record.accountId, record.hdIndex,
        exposure: record.exposure, net: record.net, balance: record.balance);
  }

  records.Address toRecord() {
    return record;
  }
}
