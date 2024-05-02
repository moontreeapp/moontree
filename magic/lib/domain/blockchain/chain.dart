import 'package:moontree_utils/moontree_utils.dart';

//var chains = {
//  Chain.ravencoin: ravencoin,
//  Chain.evrmore: evrmore,
//};

enum Chain {
  none,
  evrmore,
  ravencoin;

  static Chain from(String s) {
    s = s.toLowerCase();
    if (s.startsWith('r')) {
      return Chain.ravencoin;
    } else if (s.startsWith('e')) {
      return Chain.evrmore;
    } else {
      return Chain.none;
    }
  }

  String get symbol {
    switch (this) {
      case Chain.ravencoin:
        return 'RVN';
      case Chain.evrmore:
        return 'EVR';
      case Chain.none:
        return '';
    }
  }

  String get title => name.toTitleCase();

  String get domain {
    switch (this) {
      case Chain.ravencoin:
        return 'moontree.com';
      case Chain.evrmore:
        return 'moontree.com';
      case Chain.none:
        return 'moontree.com';
    }
  }

  int get port {
    switch (this) {
      case Chain.ravencoin:
        return 50002;
      case Chain.evrmore:
        return 50022;
      case Chain.none:
        return 50002;
    }
  }
}

String symbolName(String symbol) {
  switch (symbol) {
    case 'RVN':
      return 'Ravencoin';
    case 'EVR':
      return 'Evrmore';
    case 'RVNt':
      return 'Ravencoin (testnet)';
    case 'EVRt':
      return 'Evrmore (testnet)';
    default:
      return symbol;
  }
}

String nameSymbol(String name) {
  switch (name) {
    case 'Ravencoin':
      return 'RVN';
    case 'Evrmore':
      return 'EVR';
    case 'Ravencoin (testnet)':
      return 'RVN'; // the symbol on testnet is still the coin
    case 'Evrmore (testnet)':
      return 'EVR'; // the symbol on testnet is still the coin
    default:
      return name;
  }
}
