import 'package:flutter/material.dart';
import 'package:frontend/Core/theme/app_colors.dart';
import 'package:frontend/Core/utils/app_dimensions.dart';

// =============================================================================
// VIBRANT CRAVINGS — Flutter Theme
// Generated from Vibrant Cravings (light) & Vibrant Cravings Dark design tokens
// =============================================================================

// -----------------------------------------------------------------------------
//  COLOUR SCHEMES
// -----------------------------------------------------------------------------

const ColorScheme _lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: VibrantCravingsColors.lightPrimary,
  onPrimary: VibrantCravingsColors.lightOnPrimary,
  primaryContainer: VibrantCravingsColors.lightPrimaryContainer,
  onPrimaryContainer: VibrantCravingsColors.lightOnPrimaryContainer,
  secondary: VibrantCravingsColors.lightSecondary,
  onSecondary: VibrantCravingsColors.lightOnSecondary,
  secondaryContainer: VibrantCravingsColors.lightSecondaryContainer,
  onSecondaryContainer: VibrantCravingsColors.lightOnSecondaryContainer,
  tertiary: VibrantCravingsColors.lightTertiary,
  onTertiary: VibrantCravingsColors.lightOnTertiary,
  tertiaryContainer: VibrantCravingsColors.lightTertiaryContainer,
  onTertiaryContainer: VibrantCravingsColors.lightOnTertiaryContainer,
  error: VibrantCravingsColors.lightError,
  onError: VibrantCravingsColors.lightOnError,
  errorContainer: VibrantCravingsColors.lightErrorContainer,
  onErrorContainer: VibrantCravingsColors.lightOnErrorContainer,
  surface: VibrantCravingsColors.lightSurface,
  onSurface: VibrantCravingsColors.lightOnSurface,
  onSurfaceVariant: VibrantCravingsColors.lightOnSurfaceVariant,
  outline: VibrantCravingsColors.lightOutline,
  outlineVariant: VibrantCravingsColors.lightOutlineVariant,
  inverseSurface: VibrantCravingsColors.lightInverseSurface,
  onInverseSurface: VibrantCravingsColors.lightInverseOnSurface,
  inversePrimary: VibrantCravingsColors.lightInversePrimary,
  surfaceTint: VibrantCravingsColors.lightSurfaceTint,
);

const ColorScheme _darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: VibrantCravingsColors.darkPrimary,
  onPrimary: VibrantCravingsColors.darkOnPrimary,
  primaryContainer: VibrantCravingsColors.darkPrimaryContainer,
  onPrimaryContainer: VibrantCravingsColors.darkOnPrimaryContainer,
  secondary: VibrantCravingsColors.darkSecondary,
  onSecondary: VibrantCravingsColors.darkOnSecondary,
  secondaryContainer: VibrantCravingsColors.darkSecondaryContainer,
  onSecondaryContainer: VibrantCravingsColors.darkOnSecondaryContainer,
  tertiary: VibrantCravingsColors.darkTertiary,
  onTertiary: VibrantCravingsColors.darkOnTertiary,
  tertiaryContainer: VibrantCravingsColors.darkTertiaryContainer,
  onTertiaryContainer: VibrantCravingsColors.darkOnTertiaryContainer,
  error: VibrantCravingsColors.darkError,
  onError: VibrantCravingsColors.darkOnError,
  errorContainer: VibrantCravingsColors.darkErrorContainer,
  onErrorContainer: VibrantCravingsColors.darkOnErrorContainer,
  surface: VibrantCravingsColors.darkSurface,
  onSurface: VibrantCravingsColors.darkOnSurface,
  onSurfaceVariant: VibrantCravingsColors.darkOnSurfaceVariant,
  outline: VibrantCravingsColors.darkOutline,
  outlineVariant: VibrantCravingsColors.darkOutlineVariant,
  inverseSurface: VibrantCravingsColors.darkInverseSurface,
  onInverseSurface: VibrantCravingsColors.darkInverseOnSurface,
  inversePrimary: VibrantCravingsColors.darkInversePrimary,
  surfaceTint: VibrantCravingsColors.darkSurfaceTint,
);

// -----------------------------------------------------------------------------
// TYPOGRAPHY
// -----------------------------------------------------------------------------

// Plus Jakarta Sans must be added to pubspec.yaml:
//
//   flutter:
//     fonts:
//       - family: Plus Jakarta Sans
//         fonts:
//           - asset: fonts/PlusJakartaSans-Regular.ttf    # weight: 400
//           - asset: fonts/PlusJakartaSans-Medium.ttf     # weight: 500
//           - asset: fonts/PlusJakartaSans-SemiBold.ttf   # weight: 600
//           - asset: fonts/PlusJakartaSans-Bold.ttf       # weight: 700
//           - asset: fonts/PlusJakartaSans-ExtraBold.ttf  # weight: 800
//
// Or use the google_fonts package: GoogleFonts.plusJakartaSansTextTheme()

const String _fontFamily = 'Plus Jakarta Sans';

/// Light text theme — scales from the light design tokens.
const TextTheme _lightTextTheme = TextTheme(
  // display-lg  48px / 800 / lh 56 / ls -0.02em  (dark token)
  // light token omits display-lg; we use the dark values as the design intent
  // and rely on Flutter's displayLarge slot.
  displayLarge: TextStyle(
    fontFamily: _fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w800,
    height: 56 / 48, // lineHeight / fontSize
    letterSpacing: -0.96, // -0.02em × 48px
    color: VibrantCravingsColors.lightOnBackground,
  ),

  // headline-lg  28px / 700 / lh 36 / ls -0.01em
  headlineLarge: TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 36 / 28,
    letterSpacing: -0.28,
    color: VibrantCravingsColors.lightOnBackground,
  ),

  // headline-md  20px / 700 / lh 28
  headlineMedium: TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 28 / 20,
    color: VibrantCravingsColors.lightOnBackground,
  ),

  // headline-lg-mobile  24px / 700 / lh 32
  headlineSmall: TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 32 / 24,
    color: VibrantCravingsColors.lightOnBackground,
  ),

  // body-lg  16px / 400 / lh 24
  bodyLarge: TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    color: VibrantCravingsColors.lightOnSurface,
  ),

  // body-md  14px / 400 / lh 20
  bodyMedium: TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: VibrantCravingsColors.lightOnSurface,
  ),

  // label-lg  14px / 600 / lh 20
  labelLarge: TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    color: VibrantCravingsColors.lightOnSurface,
  ),

  // label-sm  12px / 500 / lh 16
  labelSmall: TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    color: VibrantCravingsColors.lightOnSurfaceVariant,
  ),
);

/// Dark text theme — same scale, colours flipped to dark tokens.
TextTheme get _darkTextTheme => _lightTextTheme.apply(
  bodyColor: VibrantCravingsColors.darkOnSurface,
  displayColor: VibrantCravingsColors.darkOnBackground,
  decorationColor: VibrantCravingsColors.darkOnSurface,
);

// -----------------------------------------------------------------------------
// COMPONENT THEMES — shared helpers
// -----------------------------------------------------------------------------

ButtonStyle _elevatedButtonStyle(ColorScheme cs) => ElevatedButton.styleFrom(
  backgroundColor: cs.primary,
  foregroundColor: cs.onPrimary,
  minimumSize: const Size(0, 52),
  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppDimensions.radiusMax),
  ),
  textStyle: const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  ),
);

ButtonStyle _outlinedButtonStyle(ColorScheme cs) => OutlinedButton.styleFrom(
  foregroundColor: cs.primary,
  side: BorderSide(color: cs.primary, width: 2),
  minimumSize: const Size(0, 52),
  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppDimensions.radiusMax),
  ),
  textStyle: const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  ),
);

ButtonStyle _textButtonStyle(ColorScheme cs) => TextButton.styleFrom(
  foregroundColor: cs.primary,
  textStyle: const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  ),
);

InputDecorationTheme _inputDecorationTheme(ColorScheme cs) =>
    InputDecorationTheme(
      filled: true,
      fillColor: cs.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        borderSide: BorderSide(color: cs.outline, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        borderSide: BorderSide(color: cs.outlineVariant, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        borderSide: BorderSide(color: cs.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        borderSide: BorderSide(color: cs.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        borderSide: BorderSide(color: cs.error, width: 2),
      ),
      hintStyle: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: cs.onSurfaceVariant,
      ),
    );

CardThemeData _cardTheme(ColorScheme cs) => CardThemeData(
  color: cs.surfaceContainerLow,
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
  ),
  clipBehavior: Clip.antiAlias,
  margin: EdgeInsets.zero,
);

AppBarTheme _appBarTheme(ColorScheme cs, TextTheme tt) => AppBarTheme(
  backgroundColor: cs.surface.withValues(alpha: .8), // glassmorphic base
  foregroundColor: cs.onSurface,
  surfaceTintColor: Colors.transparent,
  elevation: 0,
  centerTitle: false,
  titleTextStyle: tt.headlineMedium,
  iconTheme: IconThemeData(color: cs.onSurface),
);

NavigationBarThemeData _navigationBarTheme(ColorScheme cs) =>
    NavigationBarThemeData(
      backgroundColor: cs.surface.withValues(alpha: .8), // glassmorphic
      indicatorColor: cs.primary.withValues(alpha: .15),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: cs.primary, size: 24);
        }
        return IconThemeData(color: cs.onSurfaceVariant, size: 24);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        return TextStyle(
          fontFamily: _fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: states.contains(WidgetState.selected)
              ? cs.primary
              : cs.onSurfaceVariant,
        );
      }),
      elevation: 0,
    );

ChipThemeData _chipTheme(ColorScheme cs) => ChipThemeData(
  backgroundColor: cs.surfaceContainerHigh,
  selectedColor: cs.primary,
  secondarySelectedColor: cs.primaryContainer,
  labelStyle: TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: cs.onSurface,
  ),
  secondaryLabelStyle: TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: cs.onPrimary,
  ),
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppDimensions.radiusMax),
  ),
  side: BorderSide.none,
);

BottomSheetThemeData _bottomSheetTheme(ColorScheme cs) => BottomSheetThemeData(
  backgroundColor: cs.surfaceContainerLow,
  surfaceTintColor: Colors.transparent,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(AppDimensions.radiusXl),
    ),
  ),
  elevation: 8,
);

DialogThemeData _dialogTheme(ColorScheme cs) => DialogThemeData(
  backgroundColor: cs.surfaceContainerLow,
  surfaceTintColor: Colors.transparent,
  elevation: 4,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
  ),
  titleTextStyle: TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: cs.onSurface,
  ),
  contentTextStyle: TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: cs.onSurfaceVariant,
  ),
);

DividerThemeData _dividerTheme(ColorScheme cs) =>
    DividerThemeData(color: cs.outlineVariant, thickness: 1, space: 1);

SnackBarThemeData _snackBarTheme(ColorScheme cs) => SnackBarThemeData(
  backgroundColor: cs.inverseSurface,
  contentTextStyle: TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: cs.onInverseSurface,
  ),
  actionTextColor: cs.inversePrimary,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
  ),
  behavior: SnackBarBehavior.floating,
);

FloatingActionButtonThemeData _fabTheme(ColorScheme cs) =>
    FloatingActionButtonThemeData(
      backgroundColor: cs.primary,
      foregroundColor: cs.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      elevation: 4,
    );

SwitchThemeData _switchTheme(ColorScheme cs) => SwitchThemeData(
  thumbColor: WidgetStateProperty.resolveWith((states) {
    return states.contains(WidgetState.selected) ? cs.onPrimary : cs.outline;
  }),
  trackColor: WidgetStateProperty.resolveWith((states) {
    return states.contains(WidgetState.selected)
        ? cs.primary
        : cs.surfaceContainerHighest;
  }),
);

// -----------------------------------------------------------------------------
// THEME BUILDERS
// -----------------------------------------------------------------------------

ThemeData appLightTheme() {
  const cs = _lightColorScheme;
  final tt = _lightTextTheme;

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: cs,
    scaffoldBackgroundColor: VibrantCravingsColors.lightBackground,
    fontFamily: _fontFamily,
    textTheme: tt,

    // Components
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: _elevatedButtonStyle(cs),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: _outlinedButtonStyle(cs),
    ),
    textButtonTheme: TextButtonThemeData(style: _textButtonStyle(cs)),
    inputDecorationTheme: _inputDecorationTheme(cs),
    cardTheme: _cardTheme(cs),
    appBarTheme: _appBarTheme(cs, tt),
    navigationBarTheme: _navigationBarTheme(cs),
    chipTheme: _chipTheme(cs),
    bottomSheetTheme: _bottomSheetTheme(cs),
    dialogTheme: _dialogTheme(cs),
    dividerTheme: _dividerTheme(cs),
    snackBarTheme: _snackBarTheme(cs),
    floatingActionButtonTheme: _fabTheme(cs),
    switchTheme: _switchTheme(cs),

    // Page transitions
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}

ThemeData appDarkTheme() {
  const cs = _darkColorScheme;
  final tt = _darkTextTheme;

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: cs,
    scaffoldBackgroundColor: VibrantCravingsColors.darkBackground,
    fontFamily: _fontFamily,
    textTheme: tt,

    // Components
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: _elevatedButtonStyle(cs),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: _outlinedButtonStyle(cs),
    ),
    textButtonTheme: TextButtonThemeData(style: _textButtonStyle(cs)),
    inputDecorationTheme: _inputDecorationTheme(cs),
    cardTheme: _cardTheme(cs),
    appBarTheme: _appBarTheme(cs, tt),
    navigationBarTheme: _navigationBarTheme(cs),
    chipTheme: _chipTheme(cs),
    bottomSheetTheme: _bottomSheetTheme(cs),
    dialogTheme: _dialogTheme(cs),
    dividerTheme: _dividerTheme(cs),
    snackBarTheme: _snackBarTheme(cs),
    floatingActionButtonTheme: _fabTheme(cs),
    switchTheme: _switchTheme(cs),

    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}

// -----------------------------------------------------------------------------
// 8. USAGE — wire up in main.dart
// -----------------------------------------------------------------------------
//
// MaterialApp(
//   title: 'Vibrant Cravings',
//   theme:      appLightTheme(),
//   darkTheme:  appDarkTheme(),
//   themeMode:  ThemeMode.system,   // or ThemeMode.light / ThemeMode.dark
//   home: const HomeScreen(),
// );
//
// Access theme tokens anywhere with:
//   final cs = Theme.of(context).colorScheme;
//   final tt = Theme.of(context).textTheme;
//   cs.primary          → Electric Orange (light) / Peach (dark)
//   cs.surfaceContainerLow → card background for the current mode
//   tt.headlineLarge    → dish-name headline style
//   tt.bodyMedium       → description / ingredient text
//   tt.labelSmall       → delivery time / nutritional micro-copy
