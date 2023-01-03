import 'package:flutter_test/flutter_test.dart';
import 'package:client_front/utils/params.dart';

void main() {
  test('test parseReceiveParams', () {
    expect(
        parseReceiveParams('raven:mncJWzkRmBaYvASCGaVL3da7s2ivkmmDHe?'
            'amount=100.0&label=asdf&message=asset:EEEE!'),
        {'amount': '100.0', 'label': 'asdf', 'message': 'asset:EEEE!'});
  });

  test('test requestedAsset', () {
    var request = {
      'amount': '100.0',
      'label': 'asdf',
      'message': 'asset:EEEE!'
    };
    expect(requestedAsset(request, holdings: ['MOONTREE', 'EEEE!']), 'EEEE!');
    expect(requestedAsset(request, holdings: ['MOONTREE']), 'RVN');
    expect(requestedAsset(request, current: 'MOONTREE'), 'MOONTREE');
  });

  test('test cleaning amounts Amount', () {
    expect(cleanSatAmount('100'), '100');
    expect(cleanSatAmount('21000000001'), '21000000000');
    expect(cleanSatAmount('100.0'), '100');
    expect(cleanSatAmount('0 .0'), '0');
    expect(cleanSatAmount('.1'), '0');
    expect(cleanSatAmount('-11'), '11');

    expect(cleanDecAmount('00100'), '100.0');
    expect(cleanDecAmount('21000000001'), '21000000000.0');
    expect(cleanDecAmount('100.0'), '100.0');
    expect(cleanDecAmount('0 .0'), '0.0');
    expect(cleanDecAmount('.1'), '0.1');
    expect(cleanDecAmount('-11'), '11.0');
    expect(cleanDecAmount('0 .0', zeroToBlank: true), '');

    var label = 'There is no logic yet around whats allowed in a label...';
    expect(cleanLabel(label), label);
  });
}
