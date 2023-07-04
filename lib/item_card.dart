import 'package:flutter/material.dart';

import 'item.dart';

class ItemCard extends StatelessWidget {
  final Item _item;
  final int _amount;

  ItemCard(this._item, this._amount);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      height: 190,
      clipBehavior: Clip.antiAlias,
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(side: BorderSide(width: 0.50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _image(),
          Container(
            width: 260,
            padding: const EdgeInsets.symmetric(vertical: 5),
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _item.name ?? "NO NAME",
                  style: _buildTextStyle(),
                ),
                Container(
                  width: 260,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(color: Colors.white),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Amount',
                              style: _textStyleSmall(),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '$_amount x',
                              style: _buildTextStyle(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(color: Colors.white),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Weight',
                              style: _textStyleSmall(),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              '${_item.weight * _amount} kg',
                              style: _buildTextStyle(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 260,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(color: Colors.white),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            SizedBox(width: 48, height: 48),
                            SizedBox(width: 48, height: 48),
                          ],
                        ),
                      ),
                      const SizedBox(width: 46, height: 48),
                      SizedBox(
                        width: 46,
                        height: 48,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 46,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 46,
                        height: 48,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 46,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container _image() {
    return Container(
          width: 90,
          height: 80.89,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(_item.imagePath),
              fit: BoxFit.fill,
            ),
          ),
        );
  }

  TextStyle _textStyleSmall() {
    return const TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w500,
    );
  }

  TextStyle _buildTextStyle() {
    return const TextStyle(
      color: Colors.black,
      fontSize: 32,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w500,
    );
  }
}
