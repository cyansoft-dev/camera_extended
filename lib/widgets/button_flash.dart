import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

typedef OnTap = VoidCallback;

class ButtonFlash extends StatefulWidget {
  const ButtonFlash({super.key, this.controller, this.onTap});
  final CameraController? controller;
  final OnTap? onTap;

  @override
  State<ButtonFlash> createState() => _ButtonFlashState();
}

class _ButtonFlashState extends State<ButtonFlash>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300))
      ..forward();

    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn);

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      color: Colors.black54,
      elevation: 0,
      height: 45,
      shape: const CircleBorder(
          side: BorderSide(
        width: 1,
        color: Colors.white,
      )),
      onPressed: () {
        _animationController.forward();
        widget.onTap?.call();
      },
      child: FadeTransition(
        opacity: _animation,
        child: Icon(
          flashIcon,
          size: 28,
          color: Colors.white,
        ),
      ),
    );
  }

  IconData get flashIcon {
    switch (widget.controller?.value.flashMode) {
      case FlashMode.auto:
        return Icons.flash_auto_rounded;

      case FlashMode.always:
        return Icons.flash_on_rounded;

      case FlashMode.torch:
        return Icons.flashlight_on_sharp;

      default:
        return Icons.flash_off_rounded;
    }
  }
}
