import 'package:flutter/widgets.dart';

Map populateData(context, data) => data != null && data.isNotEmpty
    ? data
    : ModalRoute.of(context)!.settings.arguments ?? {};
