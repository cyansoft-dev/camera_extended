library camera_extended;

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:intl/intl.dart';
import 'widgets/button_flash.dart';
import 'widgets/camera_view.dart';
import 'widgets/pointer_autofocus.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

import 'widgets/button_rotation.dart';

typedef OnCapture = Function(File? image);
T? _ambiguate<T>(T? value) => value;

class CameraExtended extends StatefulWidget {
  const CameraExtended({super.key, this.onCapture, this.quality = 80});
  final int quality;
  final OnCapture? onCapture;
  @override
  State<CameraExtended> createState() => _CameraExtendedState();
}

class _CameraExtendedState extends State<CameraExtended>
    with WidgetsBindingObserver {
  CameraController? _controller;

  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _baseZoomLevel = 1.0;
  double _currentZoomLevel = 1.0;
  bool _showFocusCircle = false;
  int elapsed = 0;
  double x = 0;
  double y = 0;
  File? _imageFile;
  File? _compressedImage;
  FlashMode? _currentFlashMode;
  bool _isMainCamera = true;
  List<CameraDescription> cameras = <CameraDescription>[];

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    _ambiguate(WidgetsBinding.instance)?.addObserver(this);
    getAvailableCamera();
    getPermission();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    }

    if (state == AppLifecycleState.resumed) {
      initCamera(cameraController.description);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _ambiguate(WidgetsBinding.instance)?.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _controller != null && _controller!.value.isInitialized
          ? Stack(
              fit: StackFit.expand,
              children: [
                _imageFile != null
                    ? Image.file(
                        _imageFile!,
                        fit: BoxFit.cover,
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          CameraView(controller: _controller!),
                          LayoutBuilder(builder: (context, constraints) {
                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTapDown: (details) =>
                                  onViewFinderTap(details, constraints),
                              onScaleStart: (details) {
                                _baseZoomLevel = _currentZoomLevel;
                              },
                              onScaleUpdate: onScaleUpdate,
                            );
                          }),
                          if (_showFocusCircle)
                            Positioned(
                                top: y - 25,
                                left: x - 25,
                                child: PointerAutoFocus(
                                    focusMode: _controller!.value.focusMode)),
                          if (_currentZoomLevel > 1.0)
                            Positioned(
                              top: 35,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 500),
                                  child: Container(
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.black45,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: Text(
                                        '${_currentZoomLevel.toStringAsFixed(1)}x',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 100,
                    width: double.maxFinite,
                    decoration: const BoxDecoration(color: Colors.black45),
                    child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchOutCurve: Curves.easeOut,
                        switchInCurve: Curves.easeIn,
                        transitionBuilder: (widget, animation) {
                          final inAnimation = Tween<Offset>(
                                  begin: const Offset(0.0, 1.0),
                                  end: const Offset(0.0, 0.0))
                              .animate(animation);
                          final outAnimation = Tween<Offset>(
                                  begin: const Offset(0.0, 1.0),
                                  end: const Offset(0.0, 0.0))
                              .animate(animation);

                          if (widget.key == ValueKey(elapsed)) {
                            return SlideTransition(
                              position: inAnimation,
                              child: widget,
                            );
                          } else {
                            return SlideTransition(
                              position: outAnimation,
                              child: widget,
                            );
                          }
                        },
                        child:
                            _imageFile == null ? captureButton : actionButtons),
                  ),
                )
              ],
            )
          : Container(),
    );
  }

  void resetCameraValues() async {
    _currentZoomLevel = 1.0;
    _currentExposureOffset = 0.0;
  }

  void getAvailableCamera() async {
    cameras = await availableCameras();
  }

  Future<void> initCamera(CameraDescription description) async {
    final CameraController? oldController = _controller;
    if (oldController != null) {
      _controller = null;
      await oldController.dispose();
    }

    final cameraController = CameraController(
      description,
      ResolutionPreset.max,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    _controller = cameraController;

    resetCameraValues();

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    try {
      await cameraController.initialize();
      await Future.wait([
        cameraController
            .getMinExposureOffset()
            .then((value) => _minAvailableExposureOffset = value),
        cameraController
            .getMaxExposureOffset()
            .then((value) => _maxAvailableExposureOffset = value),
        cameraController
            .getMaxZoomLevel()
            .then((value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((value) => _minAvailableZoom = value),
      ]);

      _currentFlashMode = cameraController.value.flashMode;
    } on CameraException catch (e) {
      debugPrint('Error initializing camera: $e');
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> takePicture() async {
    if (_controller!.value.isTakingPicture) {
      return;
    }

    try {
      XFile photo = await _controller!.takePicture();
      final Directory appDir = await path_provider.getTemporaryDirectory();
      final fileName =
          'IMG_${DateFormat('yyyyMMdd').format(DateTime.now())}_${DateFormat('HHmmss').format(DateTime.now())}.jpg';
      final String outPath = path.join(appDir.path, fileName);

      // File? result = await FlutterImageCompress.compressAndGetFile(
      //   photo.path,
      //   outPath,
      //   quality: widget.quality,
      //   format: CompressFormat.jpeg,
      // );

      setState(() {
        _imageFile = File(photo.path);
      });

      // _compressedImage = result;
      widget.onCapture?.call(_imageFile);
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
    }
  }

  Future<void> getPermission() async {
    await Permission.camera.request();
    final status = await Permission.camera.status;
    if (status == PermissionStatus.granted) {
      await initCamera(cameras[0]);
    }
  }

  Future<void> onScaleUpdate(ScaleUpdateDetails details) async {
    setState(() {
      _currentZoomLevel = (_baseZoomLevel * details.scale)
          .clamp(_minAvailableZoom, _maxAvailableZoom);
    });

    await _controller!.setZoomLevel(_currentZoomLevel);
  }

  Future<void> onViewFinderTap(
      TapDownDetails details, BoxConstraints constraints) async {
    if (_controller == null) {
      return;
    }

    final CameraController cameraController = _controller!;
    setState(() {
      _showFocusCircle = true;
    });

    x = details.localPosition.dx;
    y = details.localPosition.dy;

    // double fullWidth = MediaQuery.of(context).size.width;
    // double cameraHeight = fullWidth * _controller!.value.aspectRatio;

    // double xp = x / fullWidth;
    // double yp = y / cameraHeight;

    double xp = x / constraints.maxWidth;
    double yp = y / constraints.maxHeight;

    Offset offset = Offset(xp, yp);

    await cameraController.setFocusPoint(offset);
    // cameraController.setExposurePoint(offset);

    Future.delayed(const Duration(milliseconds: 1000)).whenComplete(() {
      setState(() {
        _showFocusCircle = false;
      });
    });
  }

  Widget get captureButton {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ButtonFlash(
          flashMode: _controller!.value.flashMode,
          onTap: () async {
            if (_currentFlashMode == FlashMode.off) {
              _controller!
                  .setFlashMode(FlashMode.always)
                  .then((_) => _currentFlashMode = FlashMode.always);
            }

            if (_currentFlashMode == FlashMode.always) {
              _controller!
                  .setFlashMode(FlashMode.auto)
                  .then((_) => _currentFlashMode = FlashMode.auto);
            }

            if (_currentFlashMode == FlashMode.auto) {
              _controller!
                  .setFlashMode(FlashMode.torch)
                  .then((_) => _currentFlashMode = FlashMode.torch);
            }

            if (_currentFlashMode == FlashMode.torch) {
              _controller!
                  .setFlashMode(FlashMode.off)
                  .then((_) => _currentFlashMode = FlashMode.off);
            }
          },
        ),
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: 1,
                color: Colors.white,
              )),
          child: MaterialButton(
            elevation: 0,
            height: 45,
            color: Colors.white,
            shape: const CircleBorder(),
            onPressed: () => takePicture(),
          ),
        ),
        ButtonRotation(
          direction: _controller!.description.lensDirection,
          onTap: () async {
            _isMainCamera = !_isMainCamera;
            await initCamera(_isMainCamera ? cameras[0] : cameras[1]);
          },
        )
      ],
    );
  }

  Widget get actionButtons {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        MaterialButton(
            elevation: 0,
            height: 40,
            color: Colors.white,
            shape: const CircleBorder(),
            child: const Icon(
              Icons.close_rounded,
              size: 26,
            ),
            onPressed: () {
              _imageFile!.deleteSync();

              setState(() {
                _imageFile = null;
              });
            }),
        MaterialButton(
            elevation: 0,
            height: 40,
            color: Colors.white,
            shape: const CircleBorder(),
            child: const Icon(
              Icons.check_rounded,
              size: 26,
            ),
            onPressed: () {
              _imageFile!.deleteSync();
              Navigator.pop(context, _compressedImage!);
            }),
      ],
    );
  }
}
