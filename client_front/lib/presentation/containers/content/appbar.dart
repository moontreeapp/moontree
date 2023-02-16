import 'package:flutter/material.dart';
import 'package:client_front/application/widgets/title/cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_front/presentation/services/services.dart' as uiservices;

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<TitleCubit, TitleCubitState>(builder: (context, state) {
        if (state.navBack) {
          uiservices.sailor
              .gobackTrigger(context)
              .then((value) => BlocProvider.of<TitleCubit>(context).update(
                    title: state.title,
                    navBack: false,
                  ));
        }
        return Row(
          children: [
            Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                height: uiservices.screen.app.appBarHeight,
                child: GestureDetector(
                  onTap: () async =>
                      await uiservices.sailor.gobackTrigger(context),
                  // Todo: key this off something else. like sailor current path or something
                  child: ['Menu', 'Holdings', 'Manage'].contains(state.title)
                      ? const Icon(Icons.menu, color: Colors.white)
                      : const Icon(Icons.arrow_back, color: Colors.white),
                )),
            Text(
              style: const TextStyle(fontSize: 16, color: Colors.white),
              state.title,
            ),
          ],
        );
      });
}
