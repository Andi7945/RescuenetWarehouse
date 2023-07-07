import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/routes.dart';

class Menu extends StatelessWidget {
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
          _option('Container with content', routeContainerWithContent, context),
          _option('All Items', routeItemsOverview, context),
          _option('All containers', routeContainerOverview, context),
          _option('Work Log', routeWorkLog, context),
          _option('Export', routeExport, context)
        ],
      ),
    );
  }

  Container _option(String text, String route, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(color: Color(0xFFD9D9D9)),
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

  TextStyle _textStyle() {
    return const TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w700,
    );
  }
}
