library camera_extended;

import 'package:camera_extended/widgets/camera_view.dart';
import 'package:flutter/material.dart';

class CameraExtended extends StatelessWidget {
  const CameraExtended(
      {super.key,
      this.onCapture,
      this.onErrorBuilder,
      this.child,
      this.quality = 100});
  final int quality;
  final OnCapture? onCapture;
  final ErrorBuilder? onErrorBuilder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CameraView(
                quality: quality,
                onCapture: onCapture,
                onErrorBuilder: onErrorBuilder,
              ),
            ));
      },
      child: child,
    );
  }
}
