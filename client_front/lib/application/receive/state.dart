/// I think the uri feature is premature right now, there's no guarantee we'll
/// want to implement it to be compatible with the QT, so I copied the old logic
/// over here for easy access but commented it all out because I don't think we
/// should implement it yet. Just get the address and display it to the user.

part of 'cubit.dart';

@immutable
class ReceiveViewState extends CubitState {
  final Address? address;
  //final String message;
  //final double? amount;
  //final String label;
  //final String uri; // should be a function only on cubit probably.
  //final String username;
  //final String? error;
  //final List<Security> fetchedNames;
  final bool isSubmitting;
  // for address so that we never hit the endpoint multiple times with
  // the same input as last time. This also allows us to set the wallet and

  const ReceiveViewState({
    required this.address,
    //required this.message,
    //required this.amount,
    //required this.label,
    //required this.uri,
    //required this.username,
    //required this.error,
    //required this.fetchedNames,
    required this.isSubmitting,
  });

  @override
  String toString() => 'HoldingsViewSate( '
      'address=$address, '
      //'message=$message, '
      //'amount=$amount, '
      //'label=$label, '
      //'uri=$uri, '
      //'username=$username, '
      //'error=$error, '
      //'fetchedNames=$fetchedNames, '
      'isSubmitting=$isSubmitting)';

  @override
  List<Object?> get props => <Object?>[
        address,
        //message,
        //amount,
        //label,
        //uri,
        //username,
        //error,
        //fetchedNames,
        isSubmitting,
      ];

  factory ReceiveViewState.initial() => ReceiveViewState(
      address: null,
      //message: '',
      //amount: 0.0,
      //label: '',
      //uri: '',
      //username: '',
      //error: null,
      //fetchedNames: null,
      isSubmitting: true);

  ReceiveViewState load({
    Address? address,
    //String? message,
    //double? amount,
    //String? label,
    //String? uri,
    //String? username,
    //String? error,
    //String? fetchedNames,
    bool? isSubmitting,
  }) =>
      ReceiveViewState(
        address: address ?? this.address,
        //message: message ?? this.message,
        //amount: amount ?? this.amount,
        //label: label ?? this.label,
        //uri: uri ?? this.uri,
        //username: username ?? this.username,
        //error: error ?? this.error,
        //fetchedNames: fetchedNames ?? this.fetchedNames,
        isSubmitting: isSubmitting ?? this.isSubmitting,
      );

  /** uri functionality, unused, copied directly from old receive screen.
   * maybe implement later.
   * 
  bool get rawAddress =>
      requestMessage.text == '' &&
      requestAmount.text == '' &&
      requestLabel.text == '';
  String _makeURI({bool refresh = true}) {
    if (rawAddress) {
      uri = address!;
    } else {
      final String amount = requestAmount.text == ''
          ? ''
          : 'amount=${Uri.encodeComponent(requestAmount.text)}';
      final String label = requestLabel.text == ''
          ? ''
          : 'label=${Uri.encodeComponent(requestLabel.text)}';
      final String message = requestMessage.text == ''
          ? ''
          //: 'message=${Uri.encodeComponent(requestMessage.text)}';
          : 'message=asset:${Uri.encodeComponent(requestMessage.text)}';
      final String to =
          username == '' ? '' : 'to=${Uri.encodeComponent(username)}';

      /// should we add the rest of the fields?
      //var net = x == '' ? '' : 'net=${Uri.encodeComponent(x)}';
      //var fee = x == '' ? '' : 'fee=${Uri.encodeComponent(x)}';
      //var note = x == '' ? '' : 'note=${Uri.encodeComponent(x)}';
      //var memo = x == '' ? '' : 'memo=${Uri.encodeComponent(x)}';

      String tail =
          <String>[amount, label, message, to].join('&').replaceAll('&&', '&');
      tail =
          '?${tail.endsWith('&') ? tail.substring(0, tail.length - 1) : tail}';
      tail = tail.length == 1 ? '' : tail;
      uri = '${pros.settings.chain.name.replaceAll('coin', '')}:$address$tail';
    }
    if (refresh) {
      setState(() {});
    }
  }
  */
}
