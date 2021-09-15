import 'package:raven_mobile/utils/string.dart';

Map<String, String> parseReceiveParams(address) =>
    Uri.parse(address).queryParameters;

String requestedAsset(Map<String, String> params,
    {List? holdings, String? current}) {
  if (params.containsKey('message')) {
    if (params['message']!.startsWith('asset:')) {
      var desired = params['message']!.substring(6);
      if ((holdings ?? []).contains(desired)) {
        return desired;
      }
    }
  }
  return current ?? 'RVN';
}

/// what else could the receiver ask for other than a specific asset?
// verify valid logic...

String verifySatAmount(String amount) {
  var text = amount.split('.')[0];
  var punctuation = ' +-*/|][}{=)(&^%#@!~`<>,?\$\\._';
  for (var ix in List<int>.generate(punctuation.length, (i) => i + 1)) {
    text = text.replaceAll(punctuation.substring(ix - 1, ix), '');
  }
  if (text == '') {
    text = '0';
  }
  if (int.parse(text) > 21000000000) {
    text = '21000000000';
  }
  return text;
}

String verifyDecAmount(String amount) {
  var punctuation = ' +-*/|][}{=)(&^%#@!~`<>?\$\\_';
  for (var ix in List<int>.generate(punctuation.length, (i) => i + 1)) {
    amount = amount.replaceAll(punctuation.substring(ix - 1, ix), '');
  }
  if (amount.length > 0) {
    if (amount.contains(',')) {
      amount = amount.replaceAll(',', '.');
    }
    if (amount.contains('.')) {
      var head = amount.split('.')[0];
      var tail = amount.split('.').sublist(1).join('');
      amount =
          head + '.' + tail.substring(0, tail.length > 8 ? 8 : tail.length);
    }
    if (RegExp(
      r"^([\d]+)?(\.)?([\d]+)?$",
      caseSensitive: false,
      multiLine: false,
    ).hasMatch(amount)) {
      if (double.parse(amount) > 21000000000) {
        amount = '21000000000';
      }
    } else {
      // tried our best
      amount = '';
    }
  }
  // removes leading 0s
  return double.parse(amount).toString();
}

String verifyLabel(String label) {
  return label;
}
