import 'package:flutter/material.dart';
import 'package:rescuenet_warehouse/indicator_expiring_date.dart';
import 'package:rescuenet_warehouse/indicator_operational_status.dart';

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
          Column(
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
                    amountWithLabel(),
                    const SizedBox(width: 10),
                    weightWithLabel(),
                  ],
                ),
              ),
              signRow(),
            ],
          ),
        ],
      ),
    );
  }

  Container signRow() {
    return Container(
      width: 260,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _bordered(),
          _bordered(),
          _bordered(),
          IndicatorExpiringDate(_item),
          IndicatorOperationalStatus(_item),
        ],
      ),
    );
  }

  Container _bordered() {
    return Container(
      width: 46,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(),
      ),
    );
  }

  Column weightWithLabel() {
    return Column(
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
    );
  }

  Column amountWithLabel() {
    return Column(
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
