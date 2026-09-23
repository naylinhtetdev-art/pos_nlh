import 'package:flutter/material.dart';

/// App-wide navigator key so services (e.g. [ApiService]) can surface UI
/// (dialogs) without a widget context.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();