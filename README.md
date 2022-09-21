# camera_extended

A Flutter package base from camera plugin.

## Getting Started

## Getting Started

In your flutter project add the dependency in your pubspec.yaml:
```yml
dependencies:
...
camera_extended:
    git:
      url: https://github.com/cyansoft-dev/camera_extended.git
      ref: master
```

## Feature
- [x] Add control the flash.
- [x] Add feature pitching for zoom in out.
- [x] Add change camera.
- [x] Can add custom widget for handling error permission.
- [x] Can setting quality of image for resize image file.
- [ ] Add video record feature.


## Usage

### importing package
```
import 'package:camera_extended/camera_extended.dart';
```
### Example
```
CameraExtended(
      quality: 80,
      onCapture: (image) {
        debugPrint(image!.path);
        widget.controller?.file = image;
      },
      child: Container(),
 );
```

### Example with custom widget for handling error permission
```
CameraExtended(
      quality: 80,
      onCapture: (image) {
        debugPrint(image!.path);
        widget.controller?.file = image;
      },
      onErrorBuilder: (context, controller) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Camera permission denied \nPlease give permission.",
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),
              MaterialButton(
                color: Colors.blue,
                onPressed: () async {
                  // add this for request permission
                  await controller.requestPermission();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified_user_rounded,
                      color: Colors.white,
                    ),
                    SizedBox(width: 5),
                    const Text(
                      "Give Permission",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    }, 
    child: Container(),
 );
```

## Android Integration

Add the following to AndroidManifest.xml:
```
<uses-permission android:name="android.permission.CAMERA"/>
```

In app/build.grade set minimum SDK version
```
minSdkVersion 21
```

## IOS Integration

Add the following to info.plist:
```
<key>NSCameraUsageDescription</key>
<string>This app needs access camera when open</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access microphone when open</string>
```