import 'package:raven_back/records/node_exposure.dart';

String getDerivationPath(int index, {exposure = NodeExposure.External}) {
  return "m/44'/175'/0'/"
      '${exposureToDerivationPathPart(exposure)}/$index';
}

String exposureToDerivationPathPart(NodeExposure exposure) =>
    {
      NodeExposure.External: '0',
      NodeExposure.Internal: '1',
    }[exposure] ??
    '';
