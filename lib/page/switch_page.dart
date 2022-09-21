import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:permission_handler/permission_handler.dart';

import '../camera_extended.dart';
import '../controller/permission_controller.dart';
import 'camera_page.dart';
import 'error_page.dart';

typedef OnCapture = Function(File? image);

class SwitchPage extends StatefulWidget {
  const SwitchPage({
    super.key,
    this.quality = 100,
    this.enableAudio,
    this.onCapture,
    this.errorBuilder,
  });
  final int quality;
  final bool? enableAudio;
  final OnCapture? onCapture;
  final OnErrorBuilder? errorBuilder;

  @override
  State<SwitchPage> createState() => _SwitchPageState();
}

class _SwitchPageState extends State<SwitchPage> {
  late PermissionController _controller;

  @override
  void initState() {
    _controller = PermissionController();
    checkPermission();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _controller,
      builder: (context, status, child) {
        if (status == null) {
          return Scaffold(
            body: Container(),
          );
        }

        if (!status) {
          if (widget.errorBuilder == null) {
            return ErrorPage(
              controller: _controller,
            );
          } else {
            return Scaffold(
              body: widget.errorBuilder!(context, _controller),
            );
          }
        }

        return CameraPage(
          quality: widget.quality,
          enableAudio: widget.enableAudio,
          onCapture: (image) async {
            if (image != null) {
              final compress = await compressImage(image);
              widget.onCapture?.call(compress);
            }
          },
        );
      },
    );
  }

  Future<void> checkPermission() async {
    final cameraStatus = await Permission.camera.status;
    final microphoneStatus = await Permission.microphone.status;
    final status = (cameraStatus == PermissionStatus.granted &&
        microphoneStatus == PermissionStatus.granted);

    _controller.setStatus(status);
  }

  Future<File?> compressImage(File originFile) async {
    String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

    try {
      final tempDir = await path_provider.getTemporaryDirectory();
      final String dirPath = '${tempDir.path}/media';
      await Directory(dirPath).create(recursive: true);
      final String filePath = '$dirPath/${timestamp()}.jpeg';

      File? imageCompress;
      if (widget.quality < 100) {
        imageCompress = await FlutterImageCompress.compressAndGetFile(
          originFile.path,
          filePath,
          quality: widget.quality,
          format: CompressFormat.jpeg,
        );

        originFile.deleteSync(recursive: true);
      } else {
        imageCompress = originFile;
      }
      return imageCompress;
    } catch (e) {
      debugPrint("Error capture image : $e");
      rethrow;
    }
  }
}
