import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescuenet_warehouse/item_filter.dart';
import 'package:rescuenet_warehouse/services/item_filter_service.dart';
import 'package:rescuenet_warehouse/ui/rescue_dropdown_button.dart';
import 'package:rescuenet_warehouse/ui/rescue_text.dart';

class ItemFilterModal extends StatefulWidget {
  const ItemFilterModal({super.key});

  @override
  State createState() => _ItemFilterModalState();
}

class _ItemFilterModalState extends State<ItemFilterModal> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) => SimpleDialog(
      title: RescueText.headline("Filter items"), children: [_body()]);

  Widget _body() {
    return FractionallySizedBox(widthFactor: 0.5, child: _filterFields());
  }

  Widget _filterFields() {
    return Consumer<ItemFilterService>(builder: (ctxt, service, _) {
      _controller.text = service.currentFilterValue ?? "";

      return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        SizedBox(
            width: 300,
            child: TextField(
                onChanged: (v) => service.setCurrentFilterValue(v),
                controller: _controller,
                style: const TextStyle(fontSize: 24.0))),
        _dropdown(service.currentFilter)
      ]);
    });
  }

  Widget _dropdown(ValueNotifier<ItemFilter?> currentFilter) =>
      RescueDropdownButton(_filterOptions(), currentFilter,
          Theme.of(context).textTheme.titleLarge);

  Map<ItemFilter, String> _filterOptions() =>
      allItemFilter.map((key, value) => MapEntry(value, value.displayName));
}
