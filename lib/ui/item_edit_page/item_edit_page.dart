import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/ui/item_edit_page/item_edit_page_additional_information.dart';
import 'package:rescuenet_warehouse/ui/item_edit_page/item_edit_page_amounts.dart';
import 'package:rescuenet_warehouse/ui/item_edit_page/item_edit_page_base_information.dart';
import 'package:rescuenet_warehouse/ui/item_edit_page/item_edit_page_signs.dart';
import 'package:rescuenet_warehouse/models/rescue_container.dart';

import '../../services/container_service.dart';
import '../../models/item.dart';
import 'item_edit_page_notes.dart';

class ItemEditPage extends StatefulWidget {
  final Item item;

  @override
  State createState() => _ItemEditPageState();

  const ItemEditPage(this.item, {super.key});
}

class _ItemEditPageState extends State<ItemEditPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ContainerService>(
        builder: (ctx, service, _) =>
            _body(service.assignmentsFor(widget.item)));
  }

  _body(Map<RescueContainer, int> assignments) {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Wrap(
          children: [
            _lane(Column(
              children: [
                ItemEditPageBaseInformation(widget.item),
                const SizedBox(height: 8),
                ItemEditPageAmounts(widget.item, assignments),
                const SizedBox(height: 8),
                ItemEditPageAdditionalInformation(widget.item)
              ],
            )),
            _lane(Column(children: [
              ItemEditPageNotes(widget.item),
              ItemEditPageSigns(widget.item)
            ])),
          ],
        ));
  }

  Widget _lane(Widget w) =>
      Container(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: w);
}
