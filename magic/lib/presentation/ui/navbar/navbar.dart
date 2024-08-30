import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/cubits.dart';
import 'package:magic/presentation/ui/navbar/sections.dart';
import 'package:magic/presentation/utils/animation.dart';
import 'package:magic/presentation/widgets/animations/sliding.dart';

class NavbarLayer extends StatelessWidget {
  const NavbarLayer({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<NavbarCubit, NavbarState>(
          builder: (BuildContext context, NavbarState state) {
        /// hide all the time solution
        //import 'package:magic/presentation/widgets/animations/hiding.dart';
        //return Hide(
        //    hidden: state.hidden,
        //    duration: slowFadeDuration,
        //    child: NavbarSections(section: state.section));

        /// drop all the time solution
        return state.transitionWidgets(state,
            onEntering: SlideOver(
                duration: slideDuration,
                delay: slideDuration,
                begin: const Offset(0, 1),
                end: const Offset(0, 0),
                child: NavbarSections(section: state.section)),
            onEntered:
                NavbarSections(section: state.section), // never triggered
            onExiting: IgnorePointer(
                ignoring: !state.active,
                child: SlideOver(
                    duration: slideDuration,
                    begin: const Offset(0, 0),
                    end: const Offset(0, 1),
                    child: NavbarSections(section: state.section))),
            onExited: const SizedBox.shrink());

        /// drop sometimes, hide other times solution
        // not implemented
      });
}
