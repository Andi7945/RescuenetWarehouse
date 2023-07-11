import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/menu_option.dart';

import 'menu.dart';

class EditModuleDestinations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      Menu(MenuOption.containerOverview),
      Expanded(child: _body())
    ]));
  }

  _body() {
    return Text("edit module destinations");
  }
}
