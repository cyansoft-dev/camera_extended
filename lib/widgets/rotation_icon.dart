import 'package:flutter/cupertino.dart';

class RotateIcon extends StatelessWidget {
  const RotateIcon({super.key, required this.icon});
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return AnimatedRotation(
          turns: orientation == Orientation.portrait ? 2 : 4,
          duration: const Duration(milliseconds: 300),
          child: icon,
        );
      },
    );
  }
}
