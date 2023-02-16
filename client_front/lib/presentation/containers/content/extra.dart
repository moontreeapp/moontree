import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_front/application/extra/cubit.dart';

class ContentExtra extends StatelessWidget {
  const ContentExtra({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ContentExtraCubit, ContentExtraState>(
          builder: (BuildContext context, ContentExtraState state) =>
              state.child);
}
