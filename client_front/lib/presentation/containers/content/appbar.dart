import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_front/application/infrastructure/location/cubit.dart';
import 'package:client_front/presentation/containers/appbar/connection.dart';
import 'package:client_front/presentation/containers/appbar/lead.dart';
import 'package:client_front/presentation/containers/appbar/title.dart';
import 'package:client_front/presentation/containers/appbar/search.dart';
import 'package:client_front/presentation/services/services.dart'
    show screen, sail;
import 'package:client_front/presentation/components/components.dart'
    as components;

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      height: screen.app.appBarHeight,
      child: BlocBuilder<LocationCubit, LocationCubitState>(
          builder: (context, state) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppBarLeft(),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    ...[
                      state.showSearchButton
                          ? SearchIndicator()
                          : SizedBox.shrink()
                    ], // only show on
                    const ConnectionLight(),
                    components.status,
                  ]),
                ],
              )));
}

class AppBarLeft extends StatelessWidget {
  const AppBarLeft({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<LocationCubit, LocationCubitState>(
          builder: (context, state) =>
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                if (PageLead.show(sail.latestLocation ?? '')) PageLead(),
                //Container(
                //    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                //    height: uiservices.screen.app.appBarHeight,
                //    child: GestureDetector(
                //      onTap: () async => await uiservices.sailor.goBack(),
                //      // Todo: key this off something else. like sailor current path or something
                //      child: ['Menu', 'Holdings', 'Manage']
                //              .contains(state.title) // key off something else.
                //          ? const Icon(Icons.menu, color: Colors.white)
                //          : const Icon(Icons.arrow_back, color: Colors.white),
                //    )),
                PageTitle(),
                //Text(
                //  style: const TextStyle(fontSize: 16, color: Colors.white),
                //  state.title,
                //),
              ]));
}
