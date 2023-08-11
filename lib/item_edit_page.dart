import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/item_edit_page_additional_information.dart';
import 'package:rescuenet_warehouse/item_edit_page_amounts.dart';
import 'package:rescuenet_warehouse/item_edit_page_base_information.dart';
import 'package:rescuenet_warehouse/item_edit_page_notes.dart';
import 'package:rescuenet_warehouse/item_edit_page_signs.dart';
import 'package:rescuenet_warehouse/rescue_container.dart';

import 'container_service.dart';
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
    return Consumer<ContainerService>(
        builder: (ctx, service, _) =>
            _body(service.assignmentsFor(widget.item)));
  }

  _body(Map<RescueContainer, int> assignments) {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ItemEditPageBaseInformation(widget.item),
                const SizedBox(height: 10),
                ItemEditPageAmounts(widget.item, assignments),
                const SizedBox(height: 10),
                ItemEditPageAdditionalInformation(widget.item)
              ],
            ),
            const SizedBox(width: 10),
            Column(children: [
              ItemEditPageNotes(widget.item),
              ItemEditPageSigns(widget.item)
            ]),
            const SizedBox(width: 10),
          ],
        ));
  }
}
