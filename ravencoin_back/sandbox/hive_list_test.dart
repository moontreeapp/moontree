// dart --no-sound-null-safety test test/unit/hive_list_test.dart --concurrency=1
import 'package:electrum_adapter/electrum_adapter.dart';
import 'package:test/test.dart';
import 'package:hive/hive.dart';
import 'package:ravencoin_back/records/records.dart';

extension GetAs on Box {
  /// they are not in temporal order, but are they in the same order?
  List<T> getListAs<T>(dynamic key, {dynamic defaultValue}) {
    return List<T>.from(get(key, defaultValue: defaultValue) ?? []);
  }
}

void main() {
  test('list save', () async {
    Hive.registerAdapter(BalanceAdapter());
    Hive.init('testdb');
    var myBox = await Hive.openBox('mylist');
    print(myBox.runtimeType);
    //await myBox.put('a', [ScripthashBalance(1, 2), ScripthashBalance(3, 4)]);
    //print(List<ScripthashBalance>.from(myBox.get('a') ?? []));
    myBox.get('a')?.map((item) => print(item.confirmed));
    print(List<ScripthashBalance>.from(myBox.get('a') ?? []).runtimeType);
    print(myBox.getListAs<ScripthashBalance>('a').runtimeType);
    await myBox.close();
    expect(true, true);
  });
}
