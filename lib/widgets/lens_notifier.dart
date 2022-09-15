import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';

class CameraNotifier extends ValueNotifier<CameraDescription?> {
  CameraNotifier(super.value);

  CameraDescription? get description => value;

  set description(CameraDescription? cameraDescription) {
    value = cameraDescription;
  }
}
