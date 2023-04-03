import 'package:client_back/services/transaction/maker.dart';
import 'package:rxdart/rxdart.dart';
import 'package:moontree_utils/moontree_utils.dart'
    show ReadableIdentifierExtension;

class ReissueStreams {
  final BehaviorSubject<GenericReissueForm?> form =
      BehaviorSubject<GenericReissueForm?>.seeded(null)..name = 'reissue.form';
  final BehaviorSubject<GenericReissueRequest?> request =
      BehaviorSubject<GenericReissueRequest?>.seeded(null)
        ..name = 'reissue.request';
  final BehaviorSubject<String?> made = BehaviorSubject<String?>.seeded(null)
    ..name = 'reissue.made';
  final BehaviorSubject<SendEstimate?> estimate =
      BehaviorSubject<SendEstimate?>.seeded(null)..name = 'reissue.estimate';
  final BehaviorSubject<String?> send = BehaviorSubject<String?>.seeded(null)
    ..name = 'reissue.send';
  final BehaviorSubject<bool?> success = BehaviorSubject<bool?>.seeded(null)
    ..name = 'reissue.success';
}

class GenericReissueForm {
  // you have to use the wallet that holds the prent
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
  final String? name;
  final String? ipfs;
  final double? quantity;
  final int? decimal;
  final String? minIpfs;
  final double? minQuantity;
  final int? minDecimal;
  final bool? reissuable;
  final String? verifier;
  final String? parent;
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

  set symbol(String? symbol) => this.symbol = symbol;

  @override
  bool operator ==(Object other) =>
      other is GenericReissueForm &&
      (other.name == name &&
          other.ipfs == ipfs &&
          other.quantity == quantity &&
          other.decimal == decimal &&
          other.minIpfs == minIpfs &&
          other.minQuantity == minQuantity &&
          other.minDecimal == minDecimal &&
          other.verifier == verifier &&
          other.reissuable == reissuable &&
          other.parent == parent);
}
