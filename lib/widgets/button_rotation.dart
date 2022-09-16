import 'package:camera_extended/widgets/rotation_icon.dart';
import 'package:flutter/material.dart';

typedef OnTap = VoidCallback;

class ButtonRotation extends StatefulWidget {
  const ButtonRotation({super.key, this.onTap});
  final OnTap? onTap;

  @override
  State<ButtonRotation> createState() => _ButtonRotationState();
}

class _ButtonRotationState extends State<ButtonRotation> {
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      elevation: 0,
      height: 45,
      shape: const CircleBorder(
          side: BorderSide(
        width: 1,
        color: Colors.white,
      )),
      onPressed: widget.onTap,
      child: const RotateIcon(
        icon: Icon(
          Icons.cached_rounded,
          size: 28,
          color: Colors.white,
        ),
      ),
    );
  }
}
