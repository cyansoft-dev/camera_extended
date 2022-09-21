library camera_extended;

import 'package:camera_extended/controller/permission_controller.dart';
import 'package:flutter/material.dart';

import 'page/switch_page.dart';

typedef OnErrorBuilder = Widget Function(
    BuildContext context, PermissionController controller);

class CameraExtended extends StatelessWidget {
  const CameraExtended(
      {super.key,
      this.onCapture,
      this.child,
      this.onErrorBuilder,
      this.quality = 100});
  final int quality;
  final OnCapture? onCapture;
  final OnErrorBuilder? onErrorBuilder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SwitchPage(
                quality: quality,
                onCapture: onCapture,
                errorBuilder: onErrorBuilder,
              ),
            ));
      },
      child: child,
    );
  }
}
