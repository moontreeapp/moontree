import 'package:rxdart/rxdart.dart';

class Create {
  final form = BehaviorSubject<GenericCreateForm?>.seeded(null);
  //final make = BehaviorSubject<SendRequest?>.seeded(null);
  //final made = BehaviorSubject<String?>.seeded(null);
  //final estimate = BehaviorSubject<SendEstimate?>.seeded(null);
  //final send = BehaviorSubject<String?>.seeded(null);
  //final success = BehaviorSubject<bool?>.seeded(null);
}

class GenericCreateForm {
  final String? name;
  final String? ipfs;
  final int? quantity;
  final String? decimal;
  final bool? reissuable;
  final String? parent; // you have to use the wallet that holds the prent

  GenericCreateForm({
    this.name,
    this.ipfs,
    this.quantity,
    this.decimal,
    this.reissuable,
    this.parent,
  });
  @override
  String toString() => 'GenericCreateForm('
      'name=$name, '
      'ipfs=$ipfs, '
      'quantity=$quantity, '
      'decimal=$decimal, '
      'reissuable=$reissuable, '
      'parent=$parent)';

  factory GenericCreateForm.merge({
    GenericCreateForm? form,
    String? name,
    String? ipfs,
    int? quantity,
    String? decimal,
    bool? reissuable,
    String? parent,
  }) {
    return GenericCreateForm(
      name: name ?? form?.name,
      ipfs: ipfs ?? form?.ipfs,
      quantity: quantity ?? form?.quantity,
      decimal: decimal ?? form?.decimal,
      reissuable: reissuable ?? form?.reissuable,
      parent: parent ?? form?.parent,
    );
  }

  set symbol(String? symbol) => this.symbol = symbol;

  @override
  bool operator ==(Object form) {
    return form is GenericCreateForm
        ? (form.name == name &&
            form.ipfs == ipfs &&
            form.quantity == quantity &&
            form.decimal == decimal &&
            form.reissuable == reissuable &&
            form.parent == parent)
        : false;
  }
}
