import 'dart:typed_data';

class PaymentData {
  String? address;
  String? memo;
  Uint8List? hash;
  Uint8List? output;
  Uint8List? signature;
  Uint8List? pubkey;
  Uint8List? input;
  List<Uint8List?>? witness;

  PaymentData(
      {this.address,
      this.memo,
      this.hash,
      this.output,
      this.pubkey,
      this.input,
      this.signature,
      this.witness});

  @override
  String toString() {
    return 'PaymentData{address: $address, memo: $memo, hash: $hash, '
        'output: $output, signature: $signature, pubkey: $pubkey, '
        'input: $input, witness: $witness}';
  }
}
