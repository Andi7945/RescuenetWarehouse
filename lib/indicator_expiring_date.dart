import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class IndicatorExpiringDate extends StatelessWidget {
  final DateTime? _nextExpiringDate;

  IndicatorExpiringDate(this._nextExpiringDate);

  @override
  Widget build(BuildContext context) {
    final date = _nextExpiringDate;
    if (date == null) {
      return _empty();
    }
    final DateFormat formatter = DateFormat('MMM yy');
    final String formatted = formatter.format(date);
    return _filled(formatted, _color(date));
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

  Widget _empty() {
    return const SizedBox(width: 46, height: 48);
  }
}
