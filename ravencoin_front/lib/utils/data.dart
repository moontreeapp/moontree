import 'package:flutter/widgets.dart';

Map<String, dynamic> populateData(
  BuildContext context,
  Map<String, dynamic> data,
) =>
    data != null && data.isNotEmpty
        ? data
        : (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{})
            as Map<String, dynamic>;
