import 'package:flutter/material.dart';

import '../models/settings_model.dart';

/// Builds the app theme from the user's display settings.
///
/// - Dark mode switches to a dark colour scheme.
/// - High contrast uses Material's high-contrast colour schemes (black on
///   white, or white on black) with thicker outlines.
/// - Large text increases every text style by 20%.
ThemeData buildAppTheme({
  required bool darkMode,
  required bool highContrast,
  required bool largeText,
}) {
  final brightness = darkMode ? Brightness.dark : Brightness.light;

  final ColorScheme colorScheme;
  if (highContrast) {
    colorScheme = darkMode
        ? const ColorScheme.highContrastDark(
            primary: Color(0xFFFFFF00),
            onPrimary: Colors.black,
            surface: Colors.black,
            onSurface: Colors.white,
          )
        : const ColorScheme.highContrastLight(
            primary: Color(0xFF00007A),
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          );
  } else {
    colorScheme = ColorScheme.fromSeed(seedColor: Colors.blue, brightness: brightness);
  }

  var theme = ThemeData(colorScheme: colorScheme, brightness: brightness);

  if (highContrast) {
    final outline = BorderSide(color: colorScheme.onSurface, width: 2);
    theme = theme.copyWith(
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        shape: Border(bottom: outline),
      ),
      cardTheme: CardTheme(
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          side: outline,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      dividerTheme: DividerThemeData(color: colorScheme.onSurface, thickness: 2),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          side: outline,
        ),
      ),
    );
  }

  // ThemeData's text styles only get their sizes from Typography when the
  // theme is localized, so merge the sizes in here, then scale them. This is
  // done for every theme (factor 1.0 or 1.2) so themes animate smoothly
  // between each other.
  const sizes = Typography.englishLike2021;
  final factor = largeText ? 1.2 : 1.0;
  theme = theme.copyWith(
    textTheme: sizes.merge(theme.textTheme).apply(fontSizeFactor: factor),
    primaryTextTheme: sizes.merge(theme.primaryTextTheme).apply(fontSizeFactor: factor),
  );

  // Buttons use the theme's text size, so "Large text" applies to them too.
  final buttonText = WidgetStatePropertyAll(theme.textTheme.titleMedium);
  ButtonStyle withText(ButtonStyle? style) => (style ?? const ButtonStyle()).copyWith(textStyle: buttonText);
  theme = theme.copyWith(
    elevatedButtonTheme: ElevatedButtonThemeData(style: withText(theme.elevatedButtonTheme.style)),
    filledButtonTheme: FilledButtonThemeData(style: withText(theme.filledButtonTheme.style)),
    outlinedButtonTheme: OutlinedButtonThemeData(style: withText(theme.outlinedButtonTheme.style)),
    textButtonTheme: TextButtonThemeData(style: withText(theme.textButtonTheme.style)),
  );

  return theme;
}

ThemeData themeFor(SettingsModel settings) => buildAppTheme(
      darkMode: settings.isDarkMode,
      highContrast: settings.isHighContrast,
      largeText: settings.isLargeText,
    );

/// Applies the "Text scaling" setting on top of the device's own text size.
class AppTextScaling extends StatelessWidget {
  const AppTextScaling({super.key, required this.enabled, required this.child});

  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    final media = MediaQuery.of(context);
    final deviceFactor = media.textScaler.scale(100) / 100;
    return MediaQuery(
      data: media.copyWith(
        textScaler: TextScaler.linear(deviceFactor * SettingsModel.textScaleBoost),
      ),
      child: child,
    );
  }
}
