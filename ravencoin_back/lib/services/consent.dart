import 'package:ravencoin_back/consent/consent_client.dart';

enum ConsentDocument {
  user_agreement,
  privacy_policy,
  risk_disclosures,
}

class Consent {
  Consent() : client = Client('$moontreeUrl/');
  static const String moontreeUrl = 'https://api.moontree.com';
  static const String textUrl = 'https://moontree.com';

  final Client client;

  Future<void> given(String deviceId, ConsentDocument consentDocument) async =>
      client.consent.given(deviceId, consentDocument.name);

  Future<bool> haveIConsented(
          String deviceId, ConsentDocument consentDocument) async =>
      client.hasGiven.consent(deviceId, consentDocument.name);
}

String documentEndpoint(ConsentDocument consentDocument) =>
    '${Consent.textUrl}/${consentDocument.name}.html';

Future<bool> discoverConsent(String deviceId) async {
  final Consent consent = Consent();
  final bool userAgreement = await consent.haveIConsented(
    deviceId,
    ConsentDocument.user_agreement,
  );
  final bool privacyPolicy = await consent.haveIConsented(
    deviceId,
    ConsentDocument.privacy_policy,
  );
  final bool riskDisclosure = await consent.haveIConsented(
    deviceId,
    ConsentDocument.risk_disclosures,
  );
  return userAgreement && privacyPolicy && riskDisclosure;
}

/// only for dev use
Future<void> uploadNewDocument() async {
  final Consent consent = Consent();
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

Future<bool> consentToAgreements(String deviceId) async {
  //uploadNewDocument();
  // consent just once
  try {
    final Consent consent = Consent();
    await consent.given(deviceId, ConsentDocument.user_agreement);
    await consent.given(deviceId, ConsentDocument.privacy_policy);
    await consent.given(deviceId, ConsentDocument.risk_disclosures);
    return true;
  } catch (e) {
    print('unable $e');
  }
  return false;
}
