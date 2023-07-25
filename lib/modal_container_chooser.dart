import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/rescue_text.dart';

import 'rescue_container.dart';
import 'store.dart';

class ModalContainerChooser extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Consumer<Store>(builder: (ctxt, store, _) {
        return SimpleDialog(
            title: RescueText.normal("Choose container"),
            children: [_buttonRow(context), ..._options(store, context)]);
      });

  Row _buttonRow(BuildContext context) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        TextButton(
            onPressed: () => _changeAll(context, true),
            child: RescueText.normal("show all")),
        TextButton(
            onPressed: () => _changeAll(context, false),
            child: RescueText.normal("show none"))
      ]);

  _changeAll(BuildContext context, bool shown) =>
      Provider.of<Store>(context, listen: false)
          .changeAllContainerVisibility(shown);

  List<Widget> _options(Store store, BuildContext context) => store
      .containerWithVisible()
      .entries
      .map((entry) => _option(context, entry))
      .toList();

  Widget _option(BuildContext context, MapEntry<RescueContainer, bool> entry) =>
      SimpleDialogOption(
        onPressed: () => _change(context, entry.key),
        child: ListTile(
          leading: Checkbox(
            value: entry.value,
            onChanged: (ev) => _change(context, entry.key),
          ),
          title: RescueText.normal(entry.key.name ?? ""),
        ),
      );

  _change(BuildContext context, RescueContainer container) =>
      Provider.of<Store>(context, listen: false)
          .changeContainerVisibility(container);
}
