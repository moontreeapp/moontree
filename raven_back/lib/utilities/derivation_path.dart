import 'package:raven_back/records/node_exposure.dart';

String getDerivationPath(String type_path, int index,
        {exposure = NodeExposure.External}) =>
    // "m/44'/175'/0'"
    '$type_path/'
    '${{
      NodeExposure.External: '0',
      NodeExposure.Internal: '1',
    }[exposure]!}/$index';
