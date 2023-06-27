import 'package:client_back/client_back.dart';

void printFullState() {
  print('addresses ${pros.addresses.records.length}');
  print('assets ${pros.assets.records.length}');
  print('balances ${pros.balances.records.length}');
  print('blocks ${pros.blocks.records.length}');
  print('ciphers ${pros.ciphers.records.length}');
  print('metadatas ${pros.metadatas.records.length}');
  print('notes ${pros.notes.records.length}');
  print('passwords ${pros.passwords.records.length}');
  print('rates ${pros.rates.records.length}');
  print('securities ${pros.securities.records.length}');
  print('settings ${pros.settings.records.length}');
  print('statuses ${pros.statuses.records.length}');
  print('transactions ${pros.transactions.records.length}');
  print('unspents ${pros.unspents.records.length}');
  print('vins ${pros.vins.records.length}');
  print('vouts ${pros.vouts.records.length}');
  print('wallets ${pros.wallets.records.length}');
}
