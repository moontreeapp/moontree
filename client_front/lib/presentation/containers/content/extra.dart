import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_front/application/extra/cubit.dart';

class ExtraContainer extends StatelessWidget {
  const ExtraContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ExtraContainerCubit, ExtraContainerState>(
          builder: (BuildContext context, ExtraContainerState state) =>
              state.child ?? SizedBox.shrink());
}
