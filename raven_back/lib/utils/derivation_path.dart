import 'package:raven_back/records/node_exposure.dart';

String getDerivationPath(int index, {exposure = NodeExposure.External}) =>
    "m/44'/175'/0'/"
    '${{
      NodeExposure.External: '0',
      NodeExposure.Internal: '1',
    }[exposure]!}/$index';
