import 'package:client_back/services/transaction/maker.dart';
import 'package:rxdart/rxdart.dart';
import 'package:moontree_utils/moontree_utils.dart'
    show ReadableIdentifierExtension;

class CreateStreams {
  final BehaviorSubject<GenericCreateForm?> form =
      BehaviorSubject<GenericCreateForm?>.seeded(null)..name = 'create.form';
  final BehaviorSubject<GenericCreateRequest?> request =
      BehaviorSubject<GenericCreateRequest?>.seeded(null)
        ..name = 'create.request';
  //final make = BehaviorSubject<SendRequest?>.seeded(null)..name = 'client.activity';
  final BehaviorSubject<String?> made = BehaviorSubject<String?>.seeded(null)
    ..name = 'create.made';
  final BehaviorSubject<SendEstimate?> estimate =
      BehaviorSubject<SendEstimate?>.seeded(null)..name = 'create.estimate';
  final BehaviorSubject<String?> send = BehaviorSubject<String?>.seeded(null)
    ..name = 'create.send';
  final BehaviorSubject<bool?> success = BehaviorSubject<bool?>.seeded(null)
    ..name = 'create.success';
}

class GenericCreateForm {
  // you have to use the wallet that holds the prent

  GenericCreateForm({
    this.name,
    this.ipfs,
    this.quantity,
    this.decimal,
    this.verifier,
    this.reissuable,
    this.parent,
  });
  factory GenericCreateForm.merge({
    GenericCreateForm? form,
    String? name,
    String? ipfs,
    double? quantity,
    int? decimal,
    String? verifier,
    bool? reissuable,
    String? parent,
  }) {
    return GenericCreateForm(
      name: name ?? form?.name,
      ipfs: ipfs ?? form?.ipfs,
      quantity: quantity ?? form?.quantity,
      decimal: decimal ?? form?.decimal,
      verifier: verifier ?? form?.verifier,
      reissuable: reissuable ?? form?.reissuable,
      parent: parent ?? form?.parent,
    );
  }
  final String? name;
  final String? ipfs;
  final double? quantity;
  final int? decimal;
  final bool? reissuable;
  final String? verifier;
  final String? parent;
  @override
  String toString() => 'GenericCreateForm('
      'name=$name, '
      'ipfs=$ipfs, '
      'quantity=$quantity, '
      'decimal=$decimal, '
      'verifier=$verifier, '
      'reissuable=$reissuable, '
      'parent=$parent)';

  set symbol(String? symbol) => this.symbol = symbol;

  @override
  bool operator ==(Object other) =>
      other is GenericCreateForm &&
      (other.name == name &&
          other.ipfs == ipfs &&
          other.quantity == quantity &&
          other.decimal == decimal &&
          other.verifier == verifier &&
          other.reissuable == reissuable &&
          other.parent == parent);
}
