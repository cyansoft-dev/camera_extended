import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

typedef OnTap = VoidCallback;

class ButtonRotation extends StatelessWidget {
  const ButtonRotation({super.key, required this.direction, this.onTap});
  final CameraLensDirection direction;
  final OnTap? onTap;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      elevation: 0,
      height: 40,
      shape: const CircleBorder(
          side: BorderSide(
        width: 1,
        color: Colors.white,
      )),
      onPressed: onTap,
      child: RotatedBox(
        quarterTurns: direction == CameraLensDirection.back ? 2 : 4,
        child: const Icon(
          Icons.cached_rounded,
          size: 28,
          color: Colors.white,
        ),
      ),
    );
  }
}
