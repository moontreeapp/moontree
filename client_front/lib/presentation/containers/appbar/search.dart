import 'package:client_front/application/infrastructure/search/cubit.dart';
import 'package:flutter/material.dart';
import 'package:client_front/presentation/utils/animation.dart' as animation;
import 'package:client_front/presentation/components/components.dart'
    as components;
import 'package:client_front/presentation/widgets/other/fading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchIndicator extends StatelessWidget {
  const SearchIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<SearchCubit, SearchCubitState>(
          builder: (BuildContext context, SearchCubitState state) => FadeIn(
                duration: animation.fadeDuration,
                child: AnimatedContainer(
                    duration: animation.fadeDuration,
                    alignment: Alignment.center,
                    padding: EdgeInsets.zero,
                    width: 48,
                    child: IconButton(
                      splashRadius: 16,
                      padding: EdgeInsets.zero,
                      icon: components.cubits.search.shown
                          ? Icon(Icons.close_rounded, color: Colors.white)
                          : Icon(Icons.search_rounded, color: Colors.white),
                      onPressed: () {
                        if (components.cubits.search.shown) {
                          FocusScope.of(context).unfocus();
                          components.cubits.search.reset();
                        } else {
                          components.cubits.search.update(show: true);
                        }
                      },
                    )),
              ));
}
