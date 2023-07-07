import 'package:flutter/material.dart';

class ItemEditPage extends StatefulWidget {
  final String id;

  @override
  State createState() => _ItemEditPageState();

  ItemEditPage(this.id);
}

class _ItemEditPageState extends State<ItemEditPage> {
  @override
  Widget build(BuildContext context) {
    return Text("Hello ${widget.id}");
  }
}
