import 'package:flutter/material.dart';

import 'item.dart';

class ItemEditPage extends StatefulWidget {
  final Item item;

  @override
  State createState() => _ItemEditPageState();

  ItemEditPage(this.item);
}

class _ItemEditPageState extends State<ItemEditPage> {
  @override
  Widget build(BuildContext context) {
    return Text("Hello ${widget.item.name}");
  }
}
