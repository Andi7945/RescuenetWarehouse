import 'package:flutter/material.dart';

import 'data_mocks.dart';
import 'rescue_container.dart';

class ContainerVisibilityService extends ChangeNotifier {
  final Map<String, bool> containerVisibility = {
    container_office.id: true,
    container_power.id: true,
    container_medical.id: true
  };

  changeContainerVisibility(RescueContainer c) {
    containerVisibility.update(c.id, (value) => !value);
    notifyListeners();
  }

  changeAllContainerVisibility(bool shown) {
    containerVisibility.updateAll((key, value) => value = shown);
    notifyListeners();
  }
}
