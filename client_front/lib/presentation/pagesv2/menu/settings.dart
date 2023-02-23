import 'package:flutter/material.dart';
import 'package:client_front/presentation/services/services.dart' show sail;

class BackMenuSettingsScreen extends StatelessWidget {
  const BackMenuSettingsScreen({Key? key}) : super(key: key ?? defaultKey);
  static const defaultKey = ValueKey('backMenuSettings');

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
        ],
      ),
    );
  }
}
