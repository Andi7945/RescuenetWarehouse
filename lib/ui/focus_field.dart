import 'package:flutter/material.dart';

class FocusField extends StatefulWidget {
  final Function onLostFocus;
  final String? initial;
  final Widget child;

  const FocusField({
    super.key,
    required this.onLostFocus,
    this.initial,
    required this.child,
  });

  @override
  State createState() => _FocusFieldState();
}

class _FocusFieldState extends State<FocusField> {
  late FocusNode myFocusNode;

  @override
  void initState() {
    super.initState();

    myFocusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: myFocusNode,
      onFocusChange: (focused) {
        if (!focused) {
          print("Lost focus in field.");
          widget.onLostFocus();
        }
      },
      child: widget.child,
    );
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    super.dispose();
  }
}
