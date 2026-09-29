import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

abstract final class RouteService {
  static Future<T?> toNextScreen<T>(BuildContext context, Widget screen) {
    return Navigator.of(
      context,
    ).push<T>(PageTransition<T>(type: PageTransitionType.fade, child: screen));
  }

  static Future<T?> toNextScreenSlide<T>(BuildContext context, Widget screen) {
    return Navigator.of(context).push<T>(
      PageTransition<T>(type: PageTransitionType.rightToLeft, child: screen),
    );
  }

  static Future<T?> toNextScreenScale<T>(BuildContext context, Widget screen) {
    return Navigator.of(context).push<T>(
      PageTransition<T>(
        type: PageTransitionType.scale,
        alignment: Alignment.center,
        child: screen,
      ),
    );
  }

  static Future<T?> toNextScreenRotate<T>(BuildContext context, Widget screen) {
    return Navigator.of(context).push<T>(
      PageTransition<T>(
        type: PageTransitionType.rotate,
        duration: const Duration(milliseconds: 300),
        child: screen,
      ),
    );
  }

  static Future<T?> toNextScreenSize<T>(BuildContext context, Widget screen) {
    return Navigator.of(context).push<T>(
      PageTransition<T>(
        type: PageTransitionType.size,
        alignment: Alignment.bottomCenter,
        child: screen,
      ),
    );
  }

  static Future<T?> toNextScreenFade<T>(BuildContext context, Widget screen) {
    return Navigator.of(context).push<T>(
      PageTransition<T>(
        type: PageTransitionType.rightToLeftWithFade,
        child: screen,
      ),
    );
  }

  static Future<T?> toPushReplacement<T>(BuildContext context, Widget screen) {
    return Navigator.of(context).pushReplacement<T, void>(
      PageTransition<T>(type: PageTransitionType.fade, child: screen),
    );
  }

  static Future<T?> toPushReplacementSlide<T>(
    BuildContext context,
    Widget screen,
  ) {
    return Navigator.of(context).pushReplacement<T, void>(
      PageTransition<T>(type: PageTransitionType.rightToLeft, child: screen),
    );
  }

  static Future<T?> toPushAndRemoveUntil<T>(
    BuildContext context,
    Widget screen,
  ) {
    return Navigator.of(context).pushAndRemoveUntil<T>(
      PageTransition<T>(type: PageTransitionType.fade, child: screen),
      (_) => false,
    );
  }

  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.of(context).pop<T>(result);
  }

  static Future<T?> popAndPush<T>(BuildContext context, Widget screen) {
    Navigator.of(context).pop();
    return Navigator.of(
      context,
    ).push<T>(PageTransition<T>(type: PageTransitionType.fade, child: screen));
  }

  static Future<T?> popUntilAndPush<T>(BuildContext context, Widget screen) {
    Navigator.of(context).popUntil((_) => false);
    return Navigator.of(
      context,
    ).push<T>(PageTransition<T>(type: PageTransitionType.fade, child: screen));
  }

  static Future<T?> toFullScreenDialog<T>(BuildContext context, Widget screen) {
    return Navigator.of(context).push<T>(
      PageTransition<T>(
        type: PageTransitionType.fade,
        duration: const Duration(milliseconds: 300),
        fullscreenDialog: true,
        child: screen,
      ),
    );
  }

  static Future<T?> toCustomTransition<T>(
    BuildContext context,
    Widget screen, {
    PageTransitionType type = PageTransitionType.fade,
    Duration duration = const Duration(milliseconds: 250),
    Duration reverseDuration = const Duration(milliseconds: 200),
    bool opaque = true,
    bool fullscreenDialog = false,
  }) {
    return Navigator.of(context).push<T>(
      PageRouteBuilder(
        opaque: opaque,
        fullscreenDialog: fullscreenDialog,
        transitionDuration: duration,
        reverseTransitionDuration: reverseDuration,
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return PageTransition(
            type: type,
            child: child,
            duration: duration,
            reverseDuration: reverseDuration,
          ).buildTransitions(context, animation, secondaryAnimation, child);
        },
      ),
    );
  }
}
