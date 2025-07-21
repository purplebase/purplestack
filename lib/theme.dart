import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final brightnessProvider = StateProvider<Brightness>((ref) => Brightness.dark);

// Theme provider that switches between light and dark
final themeProvider = Provider<ThemeData>((ref) {
  final brightness = ref.watch(brightnessProvider);
  return brightness == Brightness.light ? lightTheme : darkTheme;
});

// Helper function to scale text theme proportionally
TextTheme _scaleTextTheme(TextTheme baseTextTheme, double scaleFactor) {
  return TextTheme(
    displayLarge: baseTextTheme.displayLarge?.copyWith(
      fontSize: (baseTextTheme.displayLarge?.fontSize ?? 57) * scaleFactor,
    ),
    displayMedium: baseTextTheme.displayMedium?.copyWith(
      fontSize: (baseTextTheme.displayMedium?.fontSize ?? 45) * scaleFactor,
    ),
    displaySmall: baseTextTheme.displaySmall?.copyWith(
      fontSize: (baseTextTheme.displaySmall?.fontSize ?? 36) * scaleFactor,
    ),
    headlineLarge: baseTextTheme.headlineLarge?.copyWith(
      fontSize: (baseTextTheme.headlineLarge?.fontSize ?? 32) * scaleFactor,
    ),
    headlineMedium: baseTextTheme.headlineMedium?.copyWith(
      fontSize: (baseTextTheme.headlineMedium?.fontSize ?? 28) * scaleFactor,
    ),
    headlineSmall: baseTextTheme.headlineSmall?.copyWith(
      fontSize: (baseTextTheme.headlineSmall?.fontSize ?? 24) * scaleFactor,
    ),
    titleLarge: baseTextTheme.titleLarge?.copyWith(
      fontSize: (baseTextTheme.titleLarge?.fontSize ?? 22) * scaleFactor,
    ),
    titleMedium: baseTextTheme.titleMedium?.copyWith(
      fontSize: (baseTextTheme.titleMedium?.fontSize ?? 16) * scaleFactor,
    ),
    titleSmall: baseTextTheme.titleSmall?.copyWith(
      fontSize: (baseTextTheme.titleSmall?.fontSize ?? 14) * scaleFactor,
    ),
    bodyLarge: baseTextTheme.bodyLarge?.copyWith(
      fontSize: (baseTextTheme.bodyLarge?.fontSize ?? 16) * scaleFactor,
    ),
    bodyMedium: baseTextTheme.bodyMedium?.copyWith(
      fontSize: (baseTextTheme.bodyMedium?.fontSize ?? 14) * scaleFactor,
    ),
    bodySmall: baseTextTheme.bodySmall?.copyWith(
      fontSize: (baseTextTheme.bodySmall?.fontSize ?? 12) * scaleFactor,
    ),
    labelLarge: baseTextTheme.labelLarge?.copyWith(
      fontSize: (baseTextTheme.labelLarge?.fontSize ?? 14) * scaleFactor,
    ),
    labelMedium: baseTextTheme.labelMedium?.copyWith(
      fontSize: (baseTextTheme.labelMedium?.fontSize ?? 12) * scaleFactor,
    ),
    labelSmall: baseTextTheme.labelSmall?.copyWith(
      fontSize: (baseTextTheme.labelSmall?.fontSize ?? 11) * scaleFactor,
    ),
  );
}

// Light theme
final lightTheme =
    ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.purple,
        brightness: Brightness.light,
      ),
      typography: Typography.material2021(),
      cardTheme: const CardThemeData(elevation: 1, margin: EdgeInsets.all(8.0)),
      chipTheme: ChipThemeData(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    ).copyWith(
      textTheme: _scaleTextTheme(
        ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.purple,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ).textTheme,
        1.2, // 20% bigger fonts
      ),
    );

// Dark theme
final darkTheme =
    ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.purple,
        brightness: Brightness.dark,
      ),
      typography: Typography.material2021(),
      cardTheme: const CardThemeData(elevation: 1, margin: EdgeInsets.all(8.0)),
      chipTheme: ChipThemeData(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    ).copyWith(
      textTheme: _scaleTextTheme(
        ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.purple,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ).textTheme,
        1.2, // 20% bigger fonts
      ),
    );
