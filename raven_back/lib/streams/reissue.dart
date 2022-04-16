import 'package:raven_back/services/transaction/maker.dart';
import 'package:rxdart/rxdart.dart';

class ReissueStreams {
  final form = BehaviorSubject<GenericReissueForm?>.seeded(null);
  final request = BehaviorSubject<GenericReissueRequest?>.seeded(null);
  final made = BehaviorSubject<String?>.seeded(null);
  final estimate = BehaviorSubject<SendEstimate?>.seeded(null);
  final send = BehaviorSubject<String?>.seeded(null);
  final success = BehaviorSubject<bool?>.seeded(null);
}

class GenericReissueForm {
  final String? name;
  final String? ipfs;
  final double? quantity;
  final int? decimal;
  final String? minIpfs;
  final double? minQuantity;
  final int? minDecimal;
  final bool? reissuable;
  final String? verifier;
  final String? parent; // you have to use the wallet that holds the prent

  GenericReissueForm({
    this.name,
    this.ipfs,
    this.quantity,
    this.decimal,
    this.minIpfs,
    this.minQuantity,
    this.minDecimal,
    this.verifier,
    this.reissuable,
    this.parent,
  });
  @override
  String toString() => 'GenericReissueForm('
      'name=$name, '
      'ipfs=$ipfs, '
      'quantity=$quantity, '
      'decimal=$decimal, '
      'minIpfs=$minIpfs, '
      'minQuantity=$minQuantity, '
      'minDecimal=$minDecimal, '
      'verifier=$verifier, '
      'reissuable=$reissuable, '
      'parent=$parent)';

  factory GenericReissueForm.merge({
    GenericReissueForm? form,
    String? name,
    String? ipfs,
    double? quantity,
    int? decimal,
    String? minIpfs,
    double? minQuantity,
    int? minDecimal,
    String? verifier,
    bool? reissuable,
    String? parent,
  }) {
    return GenericReissueForm(
      name: name ?? form?.name,
      ipfs: ipfs ?? form?.ipfs,
      quantity: quantity ?? form?.quantity,
      decimal: decimal ?? form?.decimal,
      minIpfs: minIpfs ?? form?.minIpfs,
      minQuantity: minQuantity ?? form?.minQuantity,
      minDecimal: minDecimal ?? form?.minDecimal,
      verifier: verifier ?? form?.verifier,
      reissuable: reissuable ?? form?.reissuable,
      parent: parent ?? form?.parent,
    );
  }

  set symbol(String? symbol) => this.symbol = symbol;

  @override
  bool operator ==(Object form) {
    return form is GenericReissueForm
        ? (form.name == name &&
            form.ipfs == ipfs &&
            form.quantity == quantity &&
            form.decimal == decimal &&
            form.minIpfs == minIpfs &&
            form.minQuantity == minQuantity &&
            form.minDecimal == minDecimal &&
            form.verifier == verifier &&
            form.reissuable == reissuable &&
            form.parent == parent)
        : false;
  }
}
