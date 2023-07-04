import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/menu.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          height: double.infinity,
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Menu()),
    );
  }
}
