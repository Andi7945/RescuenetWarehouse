import 'package:flutter/material.dart';

import 'item.dart';

class ItemEditPageNotes extends StatelessWidget {
  final Item item;

  ItemEditPageNotes(this.item);

  @override
  Widget build(BuildContext context) {
    return _body();
  }

  _body() {
    return Container(
      width: 562,
      padding: const EdgeInsets.all(10),
      clipBehavior: Clip.antiAlias,
      decoration: const ShapeDecoration(
        shape: RoundedRectangleBorder(side: BorderSide(width: 0.50)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            child: Text(
              'Notes:\n\nBECAUSE YOU SEND US WE CAN GO; BECAUSE WE GO THEY CAN LIVE.\nRescueNet is an emergency relief, rapid response unit, deploying trained volunteer workers offering medical, light search and rescue, psychosocial support, logistical and distribution assistance etc. into disaster areas. We aim to be there within 48 hours of the event taking place.',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
