import 'dart:io';

import 'package:flutter/material.dart';

class ImageView extends StatelessWidget {
  const ImageView({super.key, required this.image});
  final File image;

  @override
  Widget build(BuildContext context) {
    final GlobalKey globalKey = GlobalKey();
    return RepaintBoundary(
      key: globalKey,
      child: Image.file(
        image,
        fit: BoxFit.cover,
      ),
    );
  }
}
