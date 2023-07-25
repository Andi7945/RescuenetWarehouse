import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/rescue_text.dart';

import 'rescue_container.dart';
import 'store.dart';

class ModalContainerChooser extends StatefulWidget {
  final Map<RescueContainer, bool> containers;

  const ModalContainerChooser(this.containers, {super.key});

  @override
  State createState() => _ModalContainerChooserState();
}

class _ModalContainerChooserState extends State<ModalContainerChooser> {
  @override
  Widget build(BuildContext context) =>
      SimpleDialog(title: RescueText.normal("Choose container"), children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          TextButton(
              onPressed: () => _changeAll(true),
              child: RescueText.normal("show all")),
          TextButton(
              onPressed: () => _changeAll(false),
              child: RescueText.normal("show none"))
        ]),
        ...widget.containers.entries.map((entry) => _option(entry)).toList()
      ]);

  _changeAll(bool shown) {
    setState(() {
      Provider.of<Store>(context, listen: false)
          .changeAllContainerVisibility(shown);
    });
  }

  Widget _option(MapEntry<RescueContainer, bool> entry) => SimpleDialogOption(
        onPressed: () => _change(entry.key),
        child: ListTile(
          leading: Checkbox(
            value: entry.value,
            onChanged: (ev) => _change(entry.key),
          ),
          title: RescueText.normal(entry.key.name ?? ""),
        ),
      );

  _change(RescueContainer container) => setState(() {
        Provider.of<Store>(context, listen: false)
            .changeContainerVisibility(container);
      });
}
