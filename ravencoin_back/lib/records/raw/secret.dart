/// in memory only record so we don't need hive
import 'package:equatable/equatable.dart';
import 'package:ravencoin_back/ravencoin_back.dart';

class Secret with EquatableMixin {
  /// ways to link to other objects:
  final String? pubkey; // Wallet.id
  final String? scripthash; // Address.id
  final int? passwordId; // Password.id
  final String secret;
  final SecretType secretType;

  Secret({
    this.pubkey,
    this.scripthash,
    this.passwordId,
    required this.secret,
    required this.secretType,
  }) {
    if (pubkey == null && scripthash == null && passwordId == null) {
      throw Exception(
          "Invalid Secret! Secrets need some kind of ID. pubkey, scripthash, and passwordId can't all be null");
    }
    if ((pubkey != null && scripthash != null) ||
        (pubkey != null && passwordId != null) ||
        (passwordId != null && scripthash != null)) {
      throw Exception(
          'Invalid Secret! Secrets must be associated with just one record type, not address and wallet.');
    }
  }

  @override
  List<Object?> get props => <Object?>[
        pubkey,
        scripthash,
        passwordId,
        secret,
        secretType,
      ];

  @override
  String toString() => toMap.toString();

  Map<String, dynamic> get toMap => <String, dynamic>{
        'pubkey': pubkey,
        'scripthash': scripthash,
        'passwordId': passwordId,
        'secret': secret,
        'secretType': secretType.name,
      };

  String get id => Secret.key(pubkey, scripthash, passwordId, secretType);

  static String key(
    String? pubkey,
    String? scripthash,
    int? passwordId,
    SecretType secretType,
  ) =>
      '$pubkey:$scripthash:$passwordId:$secretType';

  String get linkId => Secret.linkKey(pubkey, scripthash, passwordId);

  static String linkKey(String? pubkey, String? scripthash, int? passwordId) =>
      '$pubkey:$scripthash:$passwordId';
}
