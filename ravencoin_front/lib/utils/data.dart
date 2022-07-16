import 'package:flutter/widgets.dart';

Map<String, dynamic> populateData(
  BuildContext context,
  data,
) =>
    data != null && data.isNotEmpty
        ? data
        : (ModalRoute.of(context)?.settings.arguments ?? {});
