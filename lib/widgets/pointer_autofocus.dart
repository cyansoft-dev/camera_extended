import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class PointerAutoFocus extends StatelessWidget {
  const PointerAutoFocus({super.key, required this.focusMode});
  final FocusMode focusMode;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: colorFocus,
              width: 1,
            )),
        child: Center(
          child: Container(
            height: 10,
            width: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colorFocus,
                width: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color get colorFocus {
    switch (focusMode) {
      case FocusMode.locked:
        return Colors.green;
      default:
        return Colors.white;
    }
  }
}
