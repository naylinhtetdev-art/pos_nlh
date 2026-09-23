import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pos_nlh/localizations/app_localizations.dart';
import 'package:pos_nlh/providers/auth_provider.dart';
import 'package:pos_nlh/providers/item_provider.dart';
import 'package:pos_nlh/providers/language_provider.dart';
import 'package:pos_nlh/providers/theme_provider.dart';
import 'package:pos_nlh/screens/splash_screen.dart';
import 'package:pos_nlh/services/app_navigator.dart';
import 'package:pos_nlh/services/preferences_service.dart';
import 'package:pos_nlh/utils/app_theme.dart';
import 'package:pos_nlh/utils/responsive.dart';
import 'package:provider/provider.dart';

class PosApp extends StatelessWidget {
  const PosApp({required this.preferencesService, super.key});

  final PreferencesService preferencesService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<PreferencesService>.value(value: preferencesService),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(
            preferencesService,
            initialMode: preferencesService.loadThemeMode(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => LanguageProvider(
            preferencesService,
            initialLocale: preferencesService.loadLocale(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ItemProvider()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, _) {
          return ScreenUtilInit(
            designSize: tabletAwareDesignSize(context),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'POS App',
                navigatorKey: appNavigatorKey,
                theme: AppTheme.lightFor(languageProvider.locale),
                darkTheme: AppTheme.darkFor(languageProvider.locale),
                themeMode: themeProvider.themeMode,
                locale: languageProvider.locale,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: const SplashScreen(),
              );
            },
          );
        },
      ),
    );
  }
}
