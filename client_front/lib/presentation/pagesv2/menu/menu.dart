import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_front/application/bottom/modal/cubit.dart';
import 'package:client_front/application/loading/cubit.dart';
import 'package:client_front/presentation/services/services.dart' show sail;
import 'package:client_front/presentation/services/services.dart' as services;

class BackMenuScreen extends StatelessWidget {
  const BackMenuScreen({Key? key}) : super(key: key ?? defaultKey);
  static const defaultKey = ValueKey('backMenu');
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: ListView(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 16),
                height: 56,
                child: const Text(
                  style: TextStyle(color: Colors.white),
                  'Menu Item',
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 16),
                height: 56,
                child: const Text(
                  style: TextStyle(color: Colors.white),
                  'Menu Item',
                ),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => context.read<LoadingViewCubit>().show(),
                child: Container(
                  padding: const EdgeInsets.only(left: 16),
                  height: 56,
                  child: const Text(
                    style: TextStyle(color: Colors.white),
                    'Custom loading sheet',
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () async => await sail.to('/menu/settings'),
                child: Container(
                  padding: const EdgeInsets.only(left: 16),
                  height: 56,
                  child: const Text(
                    style: TextStyle(color: Colors.white),
                    'settings',
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () async => await sail.to('/settings/example'),
                child: Container(
                  padding: const EdgeInsets.only(left: 16),
                  height: 56,
                  child: const Text(
                    style: TextStyle(color: Colors.white),
                    'example setting',
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  services.screenflags.showDialog = true;
                  return await showDialog(
                          context: context,
                          builder: (context) => GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                alignment: Alignment.center,
                                child: Container(
                                  height: 200,
                                  width: 200,
                                  color: Colors.green,
                                ),
                              )))
                      .then((value) => services.screenflags.showDialog = false);
                },
                child: Container(
                  padding: const EdgeInsets.only(left: 16),
                  height: 56,
                  child: const Text(
                    style: TextStyle(color: Colors.white),
                    'dialog dismiss test',
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  services.screenflags.showModalBottomSheet = true;
                  return await showModalBottomSheet(
                      context: context,
                      builder: (_) => Container(
                            height: 200,
                            color: Colors.black,
                          )).then((value) =>
                      services.screenflags.showModalBottomSheet = false);
                },
                child: Container(
                  padding: const EdgeInsets.only(left: 16),
                  height: 56,
                  child: const Text(
                    style: TextStyle(color: Colors.white),
                    'bottom modal sheet behind',
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  services.screenflags.showModalBottomSheet = true;
                  return await showModalBottomSheet(
                      //context: sailor.mainContext, // here we should use the context of the highest widget
                      context: context,
                      builder: (_) => Container(
                            height: 200,
                            color: Colors.black,
                          )).then((value) =>
                      services.screenflags.showModalBottomSheet = false);
                },
                child: Container(
                  padding: const EdgeInsets.only(left: 16),
                  height: 56,
                  child: const Text(
                    style: TextStyle(color: Colors.white),
                    'bottom modal sheet infront',
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => context.read<BottomModalSheetCubit>().show(),
                child: Container(
                  padding: const EdgeInsets.only(left: 16),
                  height: 56,
                  child: const Text(
                    style: TextStyle(color: Colors.white),
                    'Custom bottom modal sheet always infront',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
