class Accounts {
  Map<String, String> accounts = {};
  Map<String, List<Map<String, Object>>> holdings = {};
  Map<String, List<Map<String, Object>>> transactions = {};

  static final Accounts _singleton = Accounts._();
  static Accounts get instance => _singleton;
  Accounts._();

  /// can we replace with purely reactive listeners?
  Future<void> load() async {
    Future.delayed(Duration(seconds: 3));
    accounts['accountId1'] = 'Primary';
    accounts['accountId2'] = 'Savings';
    accounts['accountId3'] = 'Other';
    holdings['accountId1'] = [];
    holdings['accountId2'] = [
      {'asset': 'duanecoin', 'amount': 50.0}
    ];
    holdings['accountId3'] = [
      {'asset': 'rvn', 'amount': 10.0}
    ];
    transactions['accountId1'] = [];
    transactions['accountId2'] = [
      {'tx': 'hash', 'asset': 'rvn', 'direction': 'in', 'amount': 100.0},
      {'tx': 'hash', 'asset': 'duanecoin', 'direction': 'in', 'amount': 50.0},
      {'tx': 'hash', 'asset': 'rvn', 'direction': 'out', 'amount': 50.0},
      {'tx': 'hash', 'asset': 'rvn', 'direction': 'out', 'amount': 50.0}
    ];
    transactions['accountId3'] = [
      {'tx': 'hash', 'asset': 'rvn', 'direction': 'in', 'amount': 10.0}
    ];
  }
}
