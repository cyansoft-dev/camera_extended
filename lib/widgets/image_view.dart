import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class ImageView extends StatelessWidget {
  const ImageView({super.key, required this.image, required this.controller});
  final File image;
  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final GlobalKey globalKey = GlobalKey();
    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * controller.value.aspectRatio;

    if (scale < 1) scale = 1 / scale;
    return RepaintBoundary(
      key: globalKey,
      child: Transform.scale(
        scale: scale,
        child: OverflowBox(
          alignment: Alignment.center,
          child: Image.file(
            image,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
