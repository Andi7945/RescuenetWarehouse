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
      decoration: const BoxDecoration(color: Colors.white),
      constraints: const BoxConstraints(maxWidth: 150),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RescueText.slim('Current location'),
          const SizedBox(height: 4),
          RescueText.normal(
              _container.currentLocation?.name ?? "", FontWeight.w700),
        ],
      ),
    );
  }
}
