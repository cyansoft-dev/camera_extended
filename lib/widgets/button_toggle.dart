import 'package:flutter/material.dart';

typedef OnTap = VoidCallback;

class ToogleButton extends StatelessWidget {
  const ToogleButton({super.key, this.onTap, this.isToogle = false});
  final bool isToogle;
  final OnTap? onTap;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      elevation: 0,
      height: 45,
      color: Colors.black54,
      shape: const CircleBorder(
          side: BorderSide(
        width: 1,
        color: Colors.white,
      )),
      onPressed: onTap,
      child: AnimatedRotation(
        turns: isToogle ? 0.5 : 0.0,
        duration: const Duration(milliseconds: 400),
        child: const Icon(
          Icons.cached_outlined,
          size: 28,
          color: Colors.white,
        ),
      ),
    );
  }
}
