import 'package:client_front/presentation/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:client_front/presentation/services/services.dart' show sailor;

class WalletHoldings extends StatelessWidget {
  const WalletHoldings({Key? key}) : super(key: key ?? defaultKey);
  static const defaultKey = ValueKey('frontHoldings');

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(0),
        children: [
              GestureDetector(
                onTap: () {
                  sailor.sailTo(
                    location: '/wallet/holding',
                    arguments: {'chainSymbol': 'WhaleStreet'},
                  );
                },
                child: const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Text('W'),
                  ),
                  title: Text('WhaleStreet'),
                ),
              ),
              GestureDetector(
                onTap: () {
                  sailor.sailTo(
                    location: '/wallet/holding',
                    arguments: {'chainSymbol': 'Moontree'},
                  );
                },
                child: const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Text('M'),
                  ),
                  title: Text('Moontree'),
                ),
              ),
              GestureDetector(
                onTap: () {
                  sailor.sailTo(
                    location: '/wallet/holding',
                    arguments: {'chainSymbol': 'Ravencoin'},
                  );
                },
                child: const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Text('R'),
                  ),
                  title: Text('Ravencoin'),
                ),
              ),
              GestureDetector(
                onTap: () {
                  sailor.sailTo(
                    location: '/wallet/holding',
                    arguments: {'chainSymbol': 'Purple Asset'},
                  );
                },
                child: const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple,
                    child: Text('P'),
                  ),
                  title: Text('Purple Asset'),
                ),
              ),
              GestureDetector(
                onTap: () {
                  sailor.sailTo(
                    location: '/wallet/holding',
                    arguments: {'chainSymbol': 'Yellow Asset'},
                  );
                },
                child: const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.yellow,
                    child: Text('Y'),
                  ),
                  title: Text('Yellow Asset'),
                ),
              ),
              GestureDetector(
                onTap: () {
                  sailor.sailTo(
                    location: '/wallet/holding',
                    arguments: {'chainSymbol': 'Pink Holding'},
                  );
                },
                child: const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.pink,
                    child: Text('P'),
                  ),
                  title: Text('Pink Holding'),
                ),
              ),
              GestureDetector(
                onTap: () {
                  sailor.sailTo(
                    location: '/wallet/holding',
                    arguments: {'chainSymbol': 'Orange Asset'},
                  );
                },
                child: const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orangeAccent,
                    child: Text('O'),
                  ),
                  title: Text('Orange Asset'),
                ),
              ),
            ] +
            [
              GestureDetector(
                onTap: () {
                  sailor.sailTo(
                    location: '/wallet/holding',
                    arguments: {'chainSymbol': 'WhaleStreet'},
                  );
                },
                child: const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Text('W'),
                  ),
                  title: Text('WhaleStreet'),
                ),
              ),
              GestureDetector(
                onTap: () {
                  sailor.sailTo(
                    location: '/wallet/holding',
                    arguments: {'chainSymbol': 'Moontree'},
                  );
                },
                child: const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Text('M'),
                  ),
                  title: Text('Moontree'),
                ),
              ),
              GestureDetector(
                onTap: () {
                  sailor.sailTo(
                    location: '/wallet/holding',
                    arguments: {'chainSymbol': 'Ravencoin'},
                  );
                },
                child: const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Text('R'),
                  ),
                  title: Text('Ravencoin'),
                ),
              ),
              GestureDetector(
                onTap: () {
                  sailor.sailTo(
                    location: '/wallet/holding',
                    arguments: {'chainSymbol': 'Purple Asset'},
                  );
                },
                child: const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple,
                    child: Text('P'),
                  ),
                  title: Text('Purple Asset'),
                ),
              ),
              GestureDetector(
                onTap: () {
                  sailor.sailTo(
                    location: '/wallet/holding',
                    arguments: {'chainSymbol': 'Yellow Asset'},
                  );
                },
                child: const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.yellow,
                    child: Text('Y'),
                  ),
                  title: Text('Yellow Asset'),
                ),
              ),
              GestureDetector(
                onTap: () {
                  sailor.sailTo(
                    location: '/wallet/holding',
                    arguments: {'chainSymbol': 'Pink Holding'},
                  );
                },
                child: const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.pink,
                    child: Text('P'),
                  ),
                  title: Text('Pink Holding'),
                ),
              ),
              GestureDetector(
                onTap: () {
                  sailor.sailTo(
                    location: '/wallet/holding',
                    arguments: {'chainSymbol': 'Orange Asset'},
                  );
                },
                child: const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orangeAccent,
                    child: Text('O'),
                  ),
                  title: Text('Orange Asset'),
                ),
              ),
            ],
      ),
    );
  }
}
