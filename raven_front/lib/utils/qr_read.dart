class QRParams {
  late String address;
  late String amount;
  late String note;
  late String addressName;
  late String symbol;
  QRParams({
required this.address,
required this.amount,
required this.note,
required this.addressName,
required this.symbol,}
);
}
  void populateFromQR(String code) {
    if (code.startsWith('raven:')) {
      sendAddress.text = code.substring(6).split('?')[0];
      var params = parseReceiveParams(code);
      if (params.containsKey('amount')) {
        sendAmount.text = cleanDecAmount(params['amount']!);
      }
      if (params.containsKey('label')) {
        sendNote.text = cleanLabel(params['label']!);
      }
      if (params.containsKey('to')) {
        addressName = cleanLabel(params['to']!);
      }
      data['symbol'] = requestedAsset(params,
          holdings: useWallet
              ? Current.walletHoldingNames(data['walletId'])
              : Current.holdingNames,
          current: data['symbol']);
    } else {
      sendAddress.text = code;
    }
  }

if (code.startsWith('raven:')) {
      sendAddress.text = code.substring(6).split('?')[0];
      var params = parseReceiveParams(code);
      if (params.containsKey('amount')) {
        sendAmount.text = cleanDecAmount(params['amount']!);
      }
      if (params.containsKey('label')) {
        sendNote.text = cleanLabel(params['label']!);
      }
      if (params.containsKey('to')) {
        addressName = cleanLabel(params['to']!);
      }
      data['symbol'] = requestedAsset(params,
          holdings: useWallet
              ? Current.walletHoldingNames(data['walletId'])
              : Current.holdingNames,
          current: data['symbol']);
    } else {
      sendAddress.text = code;
    }