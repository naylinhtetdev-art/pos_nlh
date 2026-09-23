import 'package:flutter/widgets.dart';

class AppGap extends StatelessWidget {
  const AppGap({super.key, this.height = 0, this.width = 0});

  const AppGap.height(this.height, {super.key}) : width = 0;

  const AppGap.width(this.width, {super.key}) : height = 0;

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height, width: width);
  }
}
