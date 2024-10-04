import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/digests/ripemd160.dart';
import 'package:bs58/bs58.dart';

// Utility to calculate SHA256 hash
Uint8List sha256(Uint8List data) {
  final digest = SHA256Digest();
  return digest.process(data);
}

// Utility to calculate HASH160 (RIPEMD160(SHA256(x)))
Uint8List hash160(Uint8List data) {
  return RIPEMD160Digest().process(sha256(data));
}

// Function to generate scripthash from a public key
String scripthashFromPubkey(String pubkey, prefix) {
  // prefix is blockchain.chaindata.p2shPrefix
  // Convert the public key from hex string to Uint8List
  Uint8List pubkeyBytes = Uint8List.fromList(hex.decode(pubkey));

  // Create a redeem script: OP_DUP OP_HASH160 <pubkey_hash> OP_EQUALVERIFY OP_CHECKSIG
  List<int> redeemScript = [];
  redeemScript.add(0x76); // OP_DUP
  redeemScript.add(0xA9); // OP_HASH160
  redeemScript.add(0x14); // PUSHDATA(20) - Length of the following pubkey hash
  redeemScript.addAll(hash160(pubkeyBytes)); // pubkey_hash
  redeemScript.add(0x88); // OP_EQUALVERIFY
  redeemScript.add(0xAC); // OP_CHECKSIG

  // Hash the redeem script (hash160 of the script)
  Uint8List scripthash = hash160(Uint8List.fromList(redeemScript));

  // Add the P2SH prefix (usually 0x05 for mainnet, varies by blockchain)
  List<int> prefixed = [prefix, ...scripthash];

  // Add checksum (double SHA256 of the prefixed data)
  Uint8List checksum =
      sha256(sha256(Uint8List.fromList(prefixed))).sublist(0, 4);

  // Concatenate the prefixed scripthash and checksum
  Uint8List addressBytes = Uint8List.fromList([...prefixed, ...checksum]);

  // Return the Base58Check-encoded address (scripthash)
  return base58.encode(addressBytes);
}
