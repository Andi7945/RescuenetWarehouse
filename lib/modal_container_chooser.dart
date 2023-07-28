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
            children: [_buttonRow(context), _table(store, context)]);
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

  Widget _table(Store store, BuildContext context) {
    return Table(columnWidths: const {
      0: FixedColumnWidth(100),
      1: FixedColumnWidth(700),
      2: FixedColumnWidth(100),
      3: FixedColumnWidth(100)
    }, children: [
      _header(),
      ..._options(store, context)
    ]);
  }

  TableRow _header() => TableRow(children: [
        Align(child: RescueText.normal("shown", FontWeight.w700)),
        RescueText.normal("name", FontWeight.w700),
        Align(child: RescueText.normal("deploy", FontWeight.w700)),
        Align(child: RescueText.normal("ready", FontWeight.w700)),
      ]);

  List<TableRow> _options(Store store, BuildContext context) {
    var entries = store.containerWithVisible().entries.toList();
    entries.sort((a, b) => a.key.id.compareTo(b.key.id));
    return entries.map((entry) => _option(context, entry)).toList();
  }

  TableRow _option(
      BuildContext context, MapEntry<RescueContainer, bool> entry) {
    s(Widget w) => _selectable(w, context, entry);

    return TableRow(children: [
      s(_scaledCheckbox(
          entry.value, context, entry, (_) => _change(context, entry.key))),
      s(RescueText.normal(entry.key.name ?? "")),
      s(_scaledCheckbox(entry.key.toDeploy, context, entry, null)),
      s(_scaledCheckbox(entry.key.isReady, context, entry, null)),
    ]);
  }

  _scaledCheckbox(
          bool value,
          BuildContext context,
          MapEntry<RescueContainer, bool> entry,
          ValueChanged<bool?>? onChanged) =>
      Transform.scale(
          scale: 2,
          child: Checkbox(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              value: value,
              onChanged: onChanged));

  Widget _selectable(
      Widget w, BuildContext context, MapEntry<RescueContainer, bool> entry) {
    return InkWell(
      onTap: () => _change(context, entry.key),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
        child: SizedBox(
            height: 40,
            child: Align(alignment: Alignment.centerLeft, child: w)),
      ),
    );
  }

  _change(BuildContext context, RescueContainer container) =>
      Provider.of<Store>(context, listen: false)
          .changeContainerVisibility(container);
}
