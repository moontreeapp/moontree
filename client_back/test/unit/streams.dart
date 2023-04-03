import 'package:test/test.dart';
import 'package:rxdart/subjects.dart';
import 'package:moontree_utils/moontree_utils.dart';

void main() async {
  test('stream has name', () async {
    final Stream<dynamic> ping =
        Stream<dynamic>.periodic(const Duration(seconds: 60 * 2))
          ..name = 'app.ping';
    expect(ping.name, 'app.ping');

    final BehaviorSubject<bool> verify = BehaviorSubject<bool>.seeded(false)
      ..name = 'app.verify';
    expect(verify.name, 'app.verify');
    expect(ping.name, 'app.ping');
  });
}
