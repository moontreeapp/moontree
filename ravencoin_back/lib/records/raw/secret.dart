/// in memory only record so we don't need hive
import 'package:equatable/equatable.dart';
import 'package:ravencoin_back/ravencoin_back.dart';

class Secret with EquatableMixin {
  /// ways to link to other objects:
  final String? pubkey; // Wallet.id
  final String? scripthash; // Address.id
  final String secret;
  final SecretType secretType;

  Secret({
    this.pubkey,
    this.scripthash,
    required this.secret,
    required this.secretType,
  }) {
    if (pubkey == null && scripthash == null) {
      throw Exception(
          "Invalid Secret! Secrets need some kind of ID. pubkey and scripthash can't both be null");
    }
    if (pubkey != null && scripthash != null) {
      throw Exception(
          'Invalid Secret! Secrets must be associated with just one record type, not address and wallet.');
    }
  }

  @override
  List<Object?> get props => [
        pubkey,
        scripthash,
        secret,
        secretType,
      ];

  @override
  String toString() => toMap.toString();

  Map<String, dynamic> get toMap => {
        'pubkey': pubkey,
        'scripthash': scripthash,
        'secret': secret,
        'secretType': secretType.name,
      };

  String get id => Secret.primaryId(pubkey, scripthash, secret);

  static String primaryId(String? pubkey, String? scripthash, String secret) =>
      '$pubkey:$scripthash:$secret';

  String get linkId => Secret.LinkId(pubkey, scripthash);

  static String LinkId(String? pubkey, String? scripthash) =>
      '$pubkey:$scripthash';
}
