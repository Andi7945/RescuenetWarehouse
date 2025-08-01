import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../routes.dart';
import '../repositories/auth_providers.dart';

class RescueNavigationDrawer extends ConsumerWidget {
  RescueNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);
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
                  currentUser?.email ?? 'User email',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text('Sign Out'),
              ],
            ),
            leading: const Icon(Icons.login),
            onTap: () async {
              Navigator.of(context).pop();
              await authNotifier.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
          _option('Container with content', routeContainerWithContent, context),
          _option('All Items', routeItemsOverview, context),
          _option('All containers', routeContainerOverview, context),
          Divider(),
          _option('Work Log', routeWorkLog, context),
          _option('Print Labels', routeExport, context),
          _option(
            'Assign by container',
            routeContainerAssignmentOverviewPage,
            context,
          ),
          Divider(),
          _option("Export items to csv", routeExportItemsOverview, context),
          _option("Import items from csv", routeItemImportOverview, context),
          Divider(),
          _option("Delete multiple items", routeDeleteMultipleItems, context),
        ],
      ),
    );
  }

  ListTile _option(String text, String route, BuildContext context) => ListTile(
    title: Text(text),
    leading: const Icon(Icons.list),
    onTap: () {
      Navigator.popAndPushNamed(context, route);
    },
  );
}
