import 'package:flutter/material.dart';

import 'rescue_text.dart';

class RescueTable extends StatelessWidget {
  final List<String> _headline;
  final List<TableRow> _rows;
  final Map<int, TableColumnWidth> columnWidths;

  RescueTable(this._headline, this._rows, this.columnWidths);

  @override
  Widget build(BuildContext context) {
    const BorderSide side = BorderSide(
        color: Color(0xFF000000), width: 1.0, style: BorderStyle.solid);

    var headline = _buildHeadline();
    var rows = _rows.map((e) => _addPaddingBoxes(e)).toList();

    var expandedColumnWidths = _columnWidthsWithPaddingBoxes();

    return Table(
      border:
          const TableBorder(top: side, bottom: side, horizontalInside: side),
      columnWidths: expandedColumnWidths,
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [headline, ...rows],
    );
  }

  TableRow _buildHeadline() {
    var row = TableRow(children: _headline.map(headlineCell).toList());
    return _addPaddingBoxes(row);
  }

  Widget headlineCell(e) => Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: RescueText.headline(e));

  TableRow _addPaddingBoxes(TableRow row) {
    var children =
        row.children?.expand((element) => [element, _sizedBox()]).toList();
    children?.removeLast();
    return TableRow(children: children);
  }

  Widget _sizedBox() => const SizedBox(width: 8);

  _columnWidthsWithPaddingBoxes() {
    Map<int, TableColumnWidth> expandedColumnWidths = {};

    var numberOfColumns = _headline.length;
    var j = 0;
    for (var i = 0; i < numberOfColumns; i++) {
      if (columnWidths[i] != null) {
        expandedColumnWidths[j] = columnWidths[i]!;
      }
      expandedColumnWidths[j + 1] = const FixedColumnWidth(16);
      j += 2;
    }
    return expandedColumnWidths;
  }
}
