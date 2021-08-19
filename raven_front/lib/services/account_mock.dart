class Accounts {
  Map<String, String> accounts = {};
  Map<String, Map<String, int>> holdings = {};
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
    accounts['accountId4'] = 'Company';
    holdings['accountId1'] = {};
    holdings['accountId2'] = {'Magic Musk': 50};
    holdings['accountId3'] = {'RVN': 10, 'whalecoin': 60};
    holdings['accountId4'] = {'RVN': 600}; // 500 plus tx fees
    transactions['accountId1'] = [];
    transactions['accountId2'] = [
      {'tx': 'hash', 'asset': 'RVN', 'direction': 'in', 'amount': 100},
      {'tx': 'hash', 'asset': 'Magic Musk', 'direction': 'in', 'amount': 10},
      {'tx': 'hash', 'asset': 'Magic Musk', 'direction': 'in', 'amount': 10},
      {'tx': 'hash', 'asset': 'Magic Musk', 'direction': 'in', 'amount': 10},
      {'tx': 'hash', 'asset': 'Magic Musk', 'direction': 'in', 'amount': 10},
      {'tx': 'hash', 'asset': 'Magic Musk', 'direction': 'in', 'amount': 10},
      {'tx': 'hash', 'asset': 'RVN', 'direction': 'out', 'amount': 50},
      {'tx': 'hash', 'asset': 'RVN', 'direction': 'out', 'amount': 50},
    ];
    transactions['accountId3'] = [
      {'tx': 'hash', 'asset': 'RVN', 'direction': 'in', 'amount': 10},
      {'tx': 'hash', 'asset': 'whalecoin', 'direction': 'in', 'amount': 60},
    ];
    transactions['accountId4'] = [
      {'tx': 'hash', 'asset': 'RVN', 'direction': 'in', 'amount': 600},
    ];
  }
}
