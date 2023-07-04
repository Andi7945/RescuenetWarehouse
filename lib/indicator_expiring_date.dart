import 'package:flutter/material.dart';

import 'item.dart';
import 'package:intl/intl.dart';

class IndicatorExpiringDate extends StatelessWidget {
  final Item _item;

  IndicatorExpiringDate(this._item);

  @override
  Widget build(BuildContext context) {
    if (_item.expiringDates.isEmpty) {
      return _empty();
    }
    var dates = List.from(_item.expiringDates);
    dates.sort();
    var nextExp = dates.first;
    final DateFormat formatter = DateFormat('MMM yy');
    final String formatted = formatter.format(nextExp);
    return _filled(formatted, _color(nextExp));
  }

  _color(DateTime exp) {
    var now = DateTime.now();
    if (exp.isBefore(now)) return const Color(0xFFDD3A3A);
    if (exp.isBefore(now.add(const Duration(days: 90)))) {
      return const Color(0xFFE0A348);
    }
    return const Color(0xFF32BA2F);
  }

  _filled(String formatted, Color color) {
    return Container(
        width: 46,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(),
        ),
        child: Center(
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Exp\n',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                TextSpan(
                  text: formatted,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Container _empty() {
    return Container(
      width: 46,
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(),
      ),
    );
  }
}
