import 'dart:async';
import 'dart:math';

import 'package:test/test.dart';
import 'package:equatable/equatable.dart';
import 'package:ravencoin_back/utilities/streaming_joins.dart';

class User with EquatableMixin {
  int userId;
  String name;
  User(this.userId, this.name);

  @override
  List<Object?> get props => <Object?>[userId, name];
}

class Click with EquatableMixin {
  int clickId;
  int userId;
  int x;
  int y;
  Click(this.clickId, this.userId, this.x, this.y);

  @override
  List<Object?> get props => <Object?>[clickId, userId, x, y];
}

void main() {
  test('streamingLeftJoin', () async {
    var users = [
      User(3, 'Duane'),
      User(4, 'Jordan'),
      User(2, 'Brock'),
      User(1, 'Mystery')
    ];
    var clicks = [
      Click(1, 1, 160, 100),
      Click(2, 3, 10, 50),
      Click(3, 1, 162, 103),
      Click(4, 2, 50, 50),
      Click(5, 4, 0, 0)
    ];

    var randomTest = (Duration d1, Duration d2) async {
      var userStream = Stream.periodic(d1, (i) => users[i]).take(users.length);
      var clickStream =
          Stream.periodic(d2, (i) => clicks[i]).take(clicks.length);

      var stream = streamingLeftJoin(userStream, clickStream,
          (User a) => a.userId.toString(), (Click b) => b.userId.toString());

      var result = await stream.take(5).toList();
      expect(result.length, 5);
      result.forEach((Join join) {
        expect(join.left, isA<User>());
        expect(join.right, isA<Click>());
        expect(join.left.userId, join.right.userId);
      });
    };

    var rnd = Random(199 /* random seed for deterministic RNG */);
    for (var i = 0; i < 25; i++) {
      await randomTest(
        Duration(milliseconds: (rnd.nextDouble() * 20).floor()),
        Duration(milliseconds: (rnd.nextDouble() * 20).floor()),
      );
    }
  });
}
