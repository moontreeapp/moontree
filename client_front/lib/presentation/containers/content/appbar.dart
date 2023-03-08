import 'package:client_front/application/back/cubit.dart';
import 'package:client_front/application/front/cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_front/application/location/cubit.dart';
import 'package:client_front/presentation/widgets/bottom/snackbar.dart';
import 'package:client_front/presentation/pages/appbar/connection.dart';
import 'package:client_front/presentation/pages/appbar/lead.dart';
import 'package:client_front/presentation/pages/appbar/title.dart';
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppBarLeft(),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            const ConnectionLight(),
            components.status,
            const SnackBarViewer(),
            //const PeristentKeyboardWatcher(), // shouldn't need custom keyboard logic in uiv2
          ]),
        ],
      ));
}

class AppBarLeft extends StatelessWidget {
  const AppBarLeft({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>

      /// the latest path is available in sail.latestLocation for these to use,
      /// but we need them to be rebuilt too. So either we make a cubit just for
      /// that which can rebuild things, like PathCubit or we put it on a stream
      /// like streams.app.path. if its on the stream it's nice because the back
      /// can access it, but we have to rebuild pages with listeners ourselves.
      /// if it's in a cubit that's nice because it can trigger rebuilds for us.
      /// for now, we'll just keep a duplicate of the value on this TitleCubit,
      /// but only because its easy and already in place to rebuild the page,
      /// we'll try to reference one source of truth everywhere, including the
      /// cubit itself (sail.latestLocation), that is until we make a decision.
      /// maybe we'll determin that the back doesn't need to know where they are
      /// so we'll make a PathCubit. I suppose we could put the path on multiple
      /// cubits too.
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
