import 'package:flutter/material.dart';

import '../utils/auth_util.dart';

class NavigationDrawer extends StatelessWidget {
  NavigationDrawer({Key? key}) : super(key: key);
  Auth auth = Auth();

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
              Text(auth.currentUser?.email ?? 'User email', style: const TextStyle(fontWeight: FontWeight.bold),),
              const Text('Sign Out')]),
            leading: const Icon(Icons.login),
            onTap: () async {
              Navigator.of(context).pop();
              await auth.signOut();
              //Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
          ListTile(
            title: const Text('Basic'),
            leading: const Icon(Icons.list),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          ListTile(
            title: const Text('List Tiles'),
            leading: const Icon(Icons.view_list),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/list_tile_example');
            },
          ),
          ListTile(
            title: const Text('Expansion Tiles'),
            leading: const Icon(Icons.keyboard_arrow_down),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context)
                  .pushReplacementNamed('/expansion_tile_example');
            },
          ),
          ListTile(
            title: const Text('Slivers'),
            leading: const Icon(Icons.assignment),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/sliver_example');
            },
          ),
          ListTile(
            title: const Text('Drag Into List'),
            leading: const Icon(Icons.add),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context)
                  .pushReplacementNamed('/drag_into_list_example');
            },
          ),
          ListTile(
            title: const Text('Horizontal'),
            leading: const Icon(Icons.swap_horiz),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/horizontal_example');
            },
          ),
          ListTile(
            title: const Text('Fixed Items'),
            leading: const Icon(Icons.block),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/fixed_example');
            },
          ),
          ListTile(
            title: const Text('Drag Handle'),
            leading: const Icon(Icons.drag_handle),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context)
                  .pushReplacementNamed('/drag_handle_example');
            },
          ),
        ],
      ),
    );
  }
}