import 'package:raven/models/account.dart';
import 'package:raven/reservoir/reservoir.dart';
import 'package:raven/records.dart' as records;

class AccountReservoir extends Reservoir<String, records.Account, Account> {
  AccountReservoir() : super(HiveSource('accounts')) {
    addPrimaryIndex((account) => account.id);
  }
}
