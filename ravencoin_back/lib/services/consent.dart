import 'package:ravencoin_back/consent/consent_client.dart';

enum ConsentDocument {
  user_agreement,
  privacy_policy,
  risk_disclosures,
}

class Consent {
  static const String moontreeUrl = 'https://api.moontree.com';

  final Client client;

  Consent() : client = Client('$moontreeUrl/');

  Future<void> given(String deviceId, ConsentDocument consentDocument) async =>
      await client.consent.given(deviceId, consentDocument.name);

  Future<bool> haveIConsented(
          String deviceId, ConsentDocument consentDocument) async =>
      await client.hasGiven.consent(deviceId, consentDocument.name);
}

String documentEndpoint(ConsentDocument consentDocument) {
  return '${Consent.moontreeUrl}/${consentDocument.name}.html';
}

Future<bool> discoverConsent(String deviceId) async {
  final consent = Consent();
  return await consent.haveIConsented(
        deviceId,
        ConsentDocument.user_agreement,
      ) &&
      await consent.haveIConsented(
        deviceId,
        ConsentDocument.privacy_policy,
      ) &&
      await consent.haveIConsented(
        deviceId,
        ConsentDocument.risk_disclosures,
      );
}

/// only for dev use
Future<void> uploadNewDocument() async {
  final consent = Consent();
  await consent.client.document.upload(
      'QmbjXoq2jj3ikqtJVUCAPhzmSdQY1QderYYNiDxABbMVoY',
      ConsentDocument.user_agreement.name,
      'June 17, 2022');
  await consent.client.document.upload(
      'QmfXjUQyEPxkn9ShSxtSQH8tNVhrzoLfSNtbTYm7PfKVsc',
      ConsentDocument.privacy_policy.name,
      'June 17, 2022');
  await consent.client.document.upload(
      'Qmb86hqUJNCUrpwukZtuWUqunL7GhrkwjZErmWNMbhf5HE',
      ConsentDocument.risk_disclosures.name,
      null);
}
