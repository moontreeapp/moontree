import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_front/application/back/height/cubit.dart';
import 'package:client_front/presentation/services/services.dart' show beamer;

class BackContainer extends StatelessWidget {
  const BackContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<BackContainerHeightCubit, BackContainerHeightCubitState>(
          builder: (context, state) => Container(
                width: MediaQuery.of(context).size.width,
                height: state.height,
                alignment: Alignment.bottomCenter,
                child: beamer.back(),
              ));
}
