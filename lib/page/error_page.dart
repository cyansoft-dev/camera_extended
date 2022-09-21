import 'package:flutter/material.dart';

import '../controller/permission_controller.dart';

typedef OnProcess = VoidCallback;

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key, this.controller});

  final PermissionController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("Camera permission denied",
                style: TextStyle(
                  color: Colors.black,
                )),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              onPressed: () async {
                await controller?.requestPermission();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.verified_user_rounded,
                    color: Colors.white,
                  ),
                  SizedBox(width: 5),
                  Text(
                    "Give Permission",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
