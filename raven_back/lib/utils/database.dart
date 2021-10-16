import 'dart:io';
import 'package:raven/raven.dart';
import 'package:reservoir/reservoir.dart';

Future deleteDatabase() async {
  try {
    await accounts.clear();
    await addresses.clear();
    await balances.clear();
    await rates.clear();
    await securities.clear();
    await settings.clear();
    await transactions.clear();
    await wallets.clear();
    await vins.clear();
    await vouts.clear();
  } catch (e) {
    print('clearing failed');
  }
  try {
    await (accounts.source as HiveSource).box.clear();
    await (wallets.source as HiveSource).box.clear();
    await (addresses.source as HiveSource).box.clear();
    await (securities.source as HiveSource).box.clear();
    await (transactions.source as HiveSource).box.clear();
    await (vins.source as HiveSource).box.clear();
    await (vouts.source as HiveSource).box.clear();
    await (rates.source as HiveSource).box.clear();
    await (balances.source as HiveSource).box.clear();
    await (settings.source as HiveSource).box.clear();
  } catch (e) {
    print('box clearing failed');
  }
  try {
    await Directory('database').delete(recursive: true);
  } catch (e) {
    print('database folder not found');
  }
}
