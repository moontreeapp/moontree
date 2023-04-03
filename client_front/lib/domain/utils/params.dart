import 'package:moontree_utils/moontree_utils.dart';
import 'package:wallet_utils/wallet_utils.dart' show coinsPerChain;
import 'package:client_back/proclaim/proclaim.dart';

Map<String, String> parseReceiveParams(String address) =>
    Uri.parse(address).queryParameters;

/// message=asset:MOONTREE0
String requestedAsset(
  Map<String, String> params, {
  List<String>? holdings,
  String? current,
}) {
  if (params.containsKey('message')) {
    if (params['message']!.startsWith('asset:')) {
      final String desired = params['message']!.substring(6);
      if ((holdings ?? <String>[]).contains(desired)) {
        return desired;
      }
    }
  }
  return current ?? pros.securities.currentCoin.symbol;
}

String cleanSatAmount(String amount) {
  String text = removeChars(
    amount.split('.').first,
    chars: punctuation + whiteSapce,
  );
  if (text == '') {
    text = '0';
  }
  if (int.parse(text) > coinsPerChain) {
    text = '$coinsPerChain';
  }
  return text;
}

String cleanDecAmount(
  String amount, {
  bool zeroToBlank = false,
  bool blankToZero = false,
}) {
  amount = removeChars(amount, chars: whiteSapce + punctuationMinusCurrency);
  if (amount.isNotEmpty) {
    if (amount.contains(',')) {
      amount = amount.replaceAll(',', '.');
    }
    if (amount.contains('.')) {
      final String head = amount.split('.')[0];
      final String tail = amount.split('.').sublist(1).join();
      amount = '$head.${tail.substring(0, tail.length > 8 ? 8 : tail.length)}';
    }
    if (RegExp(
      r'^([\d]+)?(\.)?([\d]+)?$',
      caseSensitive: false,
    ).hasMatch(amount)) {
      try {
        if (double.parse(amount) > coinsPerChain) {
          amount = 'coinsPerChain';
        }
      } catch (e) {
        amount = '0';
      }
    } else {
      if (blankToZero) {
        amount = '0';
      }
    }
  }
  // remove leading 0(s)
  String ret = '';
  try {
    if (amount == '') {
      if (blankToZero) {
        ret = '0';
      }
    } else {
      ret = double.parse(amount).toString();
    }
  } catch (e) {
    if (blankToZero) {
      ret = '0';
    }
  }
  if (zeroToBlank && <String>['0', '0.0'].contains(ret)) {
    return '';
  }
  return ret;
}

String enforceDivisibility(String amount, {int divisibility = 8}) {
  if (amount.contains('.')) {
    final String head = amount.split('.')[0];
    final String tail = amount.split('.').sublist(1).join();
    final String ret =
        '$head.${tail.substring(0, tail.length > divisibility ? divisibility : tail.length)}';
    if (ret.endsWith('.')) {
      return ret.substring(0, ret.length - 1);
    }
    return ret;
  }
  return amount;
}

String cleanLabel(String label) {
  return label;
}
