import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/routes.dart';
import 'package:rescuenet_warehouse/services/item_service.dart';

class ItemAddButton extends StatelessWidget {
  const ItemAddButton({super.key});

  @override
  Widget build(BuildContext context) => Consumer<ItemService>(
      builder: (ctxt, service, _) => IconButton(
          onPressed: () async {
            var id = service.newItem().id;
            Navigator.pushNamed(ctxt, routeItemEditPage, arguments: id);
          },
          icon: const Icon(Icons.add)));
}
