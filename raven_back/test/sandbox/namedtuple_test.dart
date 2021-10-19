// dart test test/sandbox/namedtuple_test.dart
import 'package:test/test.dart';

///https://stackoverflow.com/questions/24254597/how-can-you-make-dynamic-getters-setters-in-dart/24254753
class NamedTuple {
  late Map _data;

  NamedTuple(Map data) {
    _data = {};
    data.forEach((k, v) => _data[Symbol(k).toString()] = v);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.isGetter) {
      var ret = _data[invocation.memberName.toString()];
      if (ret != null) {
        return ret;
      } else {
        super.noSuchMethod(invocation);
      }
    }
    if (invocation.isSetter) {
      _data[invocation.memberName.toString().replaceAll('=', '')] =
          invocation.positionalArguments.first;
    } else {
      super.noSuchMethod(invocation);
    }
  }
}

void main() {
  test('forEach is not isolated', () {
    var myMap = {};
    myMap['color'] = 'red';
    var qaueryMap = NamedTuple(myMap);
    qaueryMap.greet = 'Hello Dart!';
    print(qaueryMap.greet); //Hello Dart!
    print(qaueryMap.color); //red
  });
}
