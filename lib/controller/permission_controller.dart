import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionController extends ValueNotifier<bool?> {
  PermissionController({bool? value}) : super(value);

  void setStatus(bool newStatus) {
    value = newStatus;
  }

  Future<void> requestPermission() async {
    var cameraStatus = await Permission.camera.status;
    if (cameraStatus != PermissionStatus.granted) {
      cameraStatus = await Permission.camera.request();
    }

    var microphoneStatus = await Permission.microphone.status;
    if (microphoneStatus != PermissionStatus.granted) {
      microphoneStatus = await Permission.microphone.request();
    }

    bool status = (cameraStatus == PermissionStatus.granted &&
        microphoneStatus == PermissionStatus.granted);

    value = status;
  }
}
