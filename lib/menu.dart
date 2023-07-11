import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/routes.dart';

import 'menu_option.dart';

class Menu extends StatelessWidget {
  final MenuOption currentOption;

  Menu(this.currentOption);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1631,
      height: 96,
      padding: const EdgeInsets.all(10),
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _option('Container with content', routeContainerWithContent,
              currentOption == MenuOption.containerWithContent, context),
          _option('All Items', routeItemsOverview,
              currentOption == MenuOption.itemOverview, context),
          _option('All containers', routeContainerOverview,
              currentOption == MenuOption.containerOverview, context),
          _option('Work Log', routeWorkLog, currentOption == MenuOption.workLog,
              context),
          _option('Export', routeExport, currentOption == MenuOption.export,
              context)
        ],
      ),
    );
  }

  Container _option(
      String text, String route, bool selected, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: _color(selected)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextButton(
              onPressed: () {
                Navigator.pushNamed(context, route);
              },
              child: Text(text, style: _textStyle()))
        ],
      ),
    );
  }

  _color(bool selected) => selected
      ? const Color.fromRGBO(73, 115, 224, 1)
      : const Color(0xFFD9D9D9);

  TextStyle _textStyle() {
    return const TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w700,
    );
  }
}
