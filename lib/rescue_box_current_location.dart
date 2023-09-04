import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/rescue_container.dart';

import 'rescue_text.dart';

class RescueBoxCurrentLocation extends StatelessWidget {
  final RescueContainer _container;

  RescueBoxCurrentLocation(this._container);

  @override
  Widget build(BuildContext context) => _body();

  Container _body() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RescueText.slim('Current location'),
          const SizedBox(height: 10),
          RescueText.normal(
              _container.currentLocation?.name ?? "", FontWeight.w700),
        ],
      ),
    );
  }
}
