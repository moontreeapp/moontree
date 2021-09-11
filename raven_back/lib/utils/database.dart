import 'dart:io';
import 'package:raven/raven.dart';
import 'package:reservoir/reservoir.dart';

Future deleteDatabase() async {
  try {
    await accounts.clear();
    await wallets.clear();
    await addresses.clear();
    await histories.clear();
    await rates.clear();
    await balances.clear();
    await settings.clear();
  } catch (e) {
    print('clearing failed');
  }
  try {
    await (accounts.source as HiveSource).box.clear();
    await (wallets.source as HiveSource).box.clear();
    await (addresses.source as HiveSource).box.clear();
    await (histories.source as HiveSource).box.clear();
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
