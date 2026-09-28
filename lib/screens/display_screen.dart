import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pos_nlh/localizations/app_localizations.dart';
import 'package:pos_nlh/utils/responsive.dart';
import 'package:pos_nlh/widgets/app_gap.dart';
import 'package:provider/provider.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

import '../providers/theme_provider.dart';

class DisplayScreen extends StatelessWidget {
  const DisplayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.theme)),
      body: ResponsiveCenter(
        maxWidth: ResponsiveContext.maxListWidth,
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            _ThemeOption(
              icon: Icons.brightness_auto,
              label: l10n.system,
              selected: themeProvider.themeMode == ThemeMode.system,
              onTap: () => themeProvider.setThemeMode(ThemeMode.system),
            ),
            AppGap.height(8.h),
            _ThemeOption(
              icon: Icons.light_mode,
              label: l10n.light,
              selected: themeProvider.themeMode == ThemeMode.light,
              onTap: () => themeProvider.setThemeMode(ThemeMode.light),
            ),
            AppGap.height(8.h),
            _ThemeOption(
              icon: Icons.dark_mode,
              label: l10n.dark,
              selected: themeProvider.themeMode == ThemeMode.dark,
              onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ZoomTapAnimation(
      onTap: onTap,
      child: Material(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12.r),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          leading: Icon(icon),
          title: Text(label),
          trailing: selected
              ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
              : null,
        ),
      ),
    );
  }
}
