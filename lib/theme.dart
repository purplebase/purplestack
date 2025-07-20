import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final brightnessProvider = StateProvider<Brightness>((ref) => Brightness.dark);

// Theme provider that switches between light and dark
final themeProvider = Provider<ThemeData>((ref) {
  final brightness = ref.watch(brightnessProvider);
  return brightness == Brightness.light ? lightTheme : darkTheme;
});

// Light theme
final lightTheme = ThemeData(
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
);

// Dark theme
final darkTheme = ThemeData(
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
);
