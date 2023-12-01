import 'package:flutter/material.dart';

import '../routes.dart';
import '../utils/auth_util.dart';

class RescueNavigationDrawer extends StatelessWidget {
  RescueNavigationDrawer({super.key});

  final Auth auth = Auth();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          const SizedBox(
            height: 80,
            child: DrawerHeader(
              child: Image(
                image: AssetImage('assets/images/LogoRN.png'),
                alignment: Alignment.centerLeft,
              ),
            ),
          ),
          ListTile(
            title: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    auth.currentUser?.email ?? 'User email',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text('Sign Out')
                ]),
            leading: const Icon(Icons.login),
            onTap: () async {
              Navigator.of(context).pop();
              await auth.signOut();
              //Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
          _option('Container with content', routeContainerWithContent, context),
          _option('All Items', routeItemsOverview, context),
          _option('All containers', routeContainerOverview, context),
          _option('Work Log', routeWorkLog, context),
          _option('Export', routeExport, context),
        ],
      ),
    );
  }

  ListTile _option(String text, String route, BuildContext context) => ListTile(
        title: Text(text),
        leading: const Icon(Icons.list),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.pushNamed(context, route);
        },
      );
}
