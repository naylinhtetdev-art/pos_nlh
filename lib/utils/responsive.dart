import 'package:flutter/material.dart';

abstract final class AppBreakpoints {
  static const double medium = 600;

  static const double expanded = 840;
}

Size tabletAwareDesignSize(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  final isTablet = size.width >= AppBreakpoints.medium;
  if (!isTablet) return const Size(375, 812);
  final isLandscape = size.width >= size.height;
  return isLandscape ? const Size(900, 600) : const Size(600, 900);
}

extension ResponsiveContext on BuildContext {
  bool get isTablet => MediaQuery.sizeOf(this).width >= AppBreakpoints.medium;

  bool get isExpanded =>
      MediaQuery.sizeOf(this).width >= AppBreakpoints.expanded;

  static const double maxPageWidth = 640;

  static const double maxListWidth = 480;
}

class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({
    required this.child,
    this.maxWidth = ResponsiveContext.maxPageWidth,
    super.key,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
