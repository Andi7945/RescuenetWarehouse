import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/models/rescue_container.dart';

import 'rescue_text.dart';

class RescueBoxSequentialBuild extends StatelessWidget {
  final RescueContainer _container;

  RescueBoxSequentialBuild(this._container, {super.key});

  @override
  Widget build(BuildContext context) => _body();

  Container _body() {
    return Container(
      width: 108,
      padding: const EdgeInsets.symmetric(vertical: 10),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: _container.sequentialBuild.color,
        shape: const RoundedRectangleBorder(side: BorderSide(width: 0.50)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const RescueText(12, 'Sequential Build'),
          RescueText.slim(
              _container.sequentialBuild.displayName, FontWeight.w700)
        ],
      ),
    );
  }
}
