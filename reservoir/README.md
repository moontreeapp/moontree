A table-like datatype with indices. Works well with [HiveDB][hive].

## Usage

A simple usage example:

```dart
import 'package:equatable/equatable.dart';
import 'package:reservoir/reservoir.dart';

class User with EquatableMixin {
  final String id;
  final String name;
  final String status;
  User(this.id, this.name, this.status);

  @override
  List<Object?> get props => [id];

  @override
  String toString() => 'User($id, $name, $status)';
}

class UserReservoir extends Reservoir<String, User> {
  late IndexMultiple byStatus;

  UserReservoir(Source<String, User> source, GetKey<String, User> getKey)
      : super(source, getKey) {
    byStatus = addIndexMultiple('status', (user) => user.status);
  }
}

void main() async {
  var source = MapSource<String, User>();
  var res = UserReservoir(source, (User user) => user.id);
  await res.save(User('1', 'John', 'active'));
  await res.save(User('2', 'Shawna', 'active'));
  await res.save(User('3', 'Meili', 'inactive'));
  print(res.byStatus.getAll('active'));
  // => (User(1, John, active), User(2, Shawna, active))
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: http://github.com/moontreeapp/reservoir/issues
[hive]: https://github.com/hivedb/hive