import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

typedef OnTap = VoidCallback;

class ButtonFlash extends StatefulWidget {
  const ButtonFlash({super.key, required this.flashMode, this.onTap});
  final FlashMode flashMode;
  final OnTap? onTap;

  @override
  State<ButtonFlash> createState() => _ButtonFlashState();
}

class _ButtonFlashState extends State<ButtonFlash>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300))
      ..forward();

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
      onPressed: () {
        _controller.forward();
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
    switch (widget.flashMode) {
      case FlashMode.off:
        return Icons.flash_off_rounded;

      case FlashMode.auto:
        return Icons.flash_auto_rounded;

      case FlashMode.always:
        return Icons.flash_on_rounded;

      default:
        return Icons.flashlight_on_sharp;
    }
  }
}
