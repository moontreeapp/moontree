import 'package:bip39/bip39.dart' as bip39;

var mnemonic = // random mnemonic for tests
    'daring field mesh message '
    'behave tenant immense shrimp '
    'asthma gadget that mammal';

var entropy = bip39.mnemonicToEntropy(mnemonic);
