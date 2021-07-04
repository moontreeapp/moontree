//import 'dart:indexed_db';
//
///// account Data
//
//class AccountDao {
//  static const String ACCOUNT_STORE_NAME = 'accounts';
//
//  final _accountStore = intMapStoreFactory.store(ACCOUNT_STORE_NAME);
//
//  Future<Database> get _db async => await AppDatabase.instance.database;
//
//  Future insert(Account account) async {
//    await _accountStore.add(await _db, account.toMap());
//  }
//
//  Future update(Account account) async {
//    final finder = Finder(filter: Filter.bykey(account.id));
//    await _accountStore.update(
//      await _db,
//      account.toMap(),
//      finder: finder,
//    );
//  }
//
//  Future delete(Account account) async {
//    final finder = Finder(filter: Filter.bykey(account.id));
//    await _accountStore.delete(
//      await _db,
//      finder: finder,
//    );
//  }
//
//  Future<List<Account>> getAllSortedByCreateDate() async {
//    final finder = Finder(sortOrders: [SortOrder('created')]);
//    final recordSnapshot = await _accountStore.find(
//      await _db,
//      finder: finder,
//    );
//    return recordSnapshots.map((snapshot) {
//      final account = Account.fromMap(snapshot.value);
//      account.id = snapshot.key;
//      return fruit;
//    }).toList();
//  }
//}
