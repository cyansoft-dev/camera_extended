import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraView extends StatelessWidget {
  final CameraController controller;

  const CameraView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scale = size.aspectRatio * controller.value.aspectRatio;

    return Transform.scale(
      scale: scale < 1 ? (1 / scale) : scale,
      child: controller.buildPreview(),
    );
  }
}
