import 'package:raven_front/utils/strings.dart';
import 'package:raven_front/utils/transform.dart';

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
  text = removeChars(text, chars: Strings.punctuation + Strings.whiteSapce);
  if (text == '') {
    text = '0';
  }
  if (int.parse(text) > 21000000000) {
    text = '21000000000';
  }
  return text;
}

String verifyDecAmount(String amount, {bool zeroToBlank = false}) {
  amount = removeChars(amount,
      chars: Strings.whiteSapce + Strings.punctuationMinusCurrency);
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
      try {
        if (double.parse(amount) > 21000000000) {
          amount = '21000000000';
        }
      } catch (e) {
        amount = '0';
      }
    } else {
      // tried our best
      amount = '0';
    }
  }
  // removes leading 0s
  var ret = '0';
  try {
    ret = double.parse(amount).toString();
  } catch (e) {
    ret = '0';
  }
  if (zeroToBlank && ['0', '0.0'].contains(ret)) {
    return '';
  }
  return ret;
}

String verifyLabel(String label) {
  return label;
}
