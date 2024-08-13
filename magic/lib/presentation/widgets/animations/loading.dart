import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:magic/services/services.dart';
//import 'package:magic/presentation/widgets/animations/shimmer.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          Container(
              alignment: Alignment.center,
              child: Transform.scale(
                  scale: 2,
                  child: const CircularProgressIndicator(strokeWidth: 1))),
          Container(
            alignment: Alignment.center,
            height: screen.pane.midHeight,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                child: Container(
                  alignment: Alignment.center,
                  width:
                      double.infinity, // Ensure the Container fills the width
                  height: screen
                      .pane.midHeight, // Match the height to your container
                  color: Colors.black.withOpacity(
                      0), // Transparent color to apply the blur only
                ),
              ),
            ),
          ),
          //const Center(
          //  child: Padding(
          //    padding: EdgeInsets.only(top: 100),
          //    child: Text(
          //      'fetching transactions...',
          //      style: TextStyle(color: Colors.white, fontSize: 12),
          //    ),
          //  ),
          //),
        ],
      );
}
