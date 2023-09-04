import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/rescue_container.dart';

import 'rescue_text.dart';

class RescueBoxModuleDestination extends StatelessWidget {
  final RescueContainer _container;

  RescueBoxModuleDestination(this._container);

  @override
  Widget build(BuildContext context) => _body();

  Container _body() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RescueText.slim('Module Destination'),
          const SizedBox(height: 10),
          RescueText.normal(
              _container.moduleDestination?.name ?? "", FontWeight.w700),
        ],
      ),
    );
  }
}
