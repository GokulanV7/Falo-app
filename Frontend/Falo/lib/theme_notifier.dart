import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

enum ThemePreference { system, light, dark, ocean, sunset }

class ThemeNotifier with ChangeNotifier {
  ThemePreference _currentThemePreference = ThemePreference.system;

  ThemePreference get currentThemePreference => _currentThemePreference;

  ThemeMode get themeMode {
    switch (_currentThemePreference) {
      case ThemePreference.light:
        return ThemeMode.light;
      case ThemePreference.dark:
      case ThemePreference.ocean:
      case ThemePreference.sunset:
        return ThemeMode.dark;
      case ThemePreference.system:
      default:
        return ThemeMode.system;
    }
  }

  ThemeData get currentTheme {
    final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
    final isSystemDark = brightness == Brightness.dark;

    switch (_currentThemePreference) {
      case ThemePreference.light:
        return lightTheme;
      case ThemePreference.dark:
        return darkTheme;
      case ThemePreference.ocean:
        return oceanTheme;
      case ThemePreference.sunset:
        return sunsetTheme;
      case ThemePreference.system:
      default:
        return isSystemDark ? darkTheme : lightTheme;
    }
  }

  void switchTheme(ThemePreference preference) {
    if (_currentThemePreference != preference) {
      _currentThemePreference = preference;
      notifyListeners();
    }
  }
}

// Helper functions for theming
TextTheme _buildTextTheme({
  required TextTheme base,
  required Color primaryColor,
  required Color secondaryColor,
}) {
  return base.copyWith(
    displayLarge: base.displayLarge?.copyWith(
      color: primaryColor,
      fontWeight: FontWeight.w900,
      fontSize: 34,
    ),
    displayMedium: base.displayMedium?.copyWith(
      color: primaryColor,
      fontWeight: FontWeight.w800,
      fontSize: 28,
    ),
    displaySmall: base.displaySmall?.copyWith(
      color: primaryColor,
      fontWeight: FontWeight.w700,
      fontSize: 24,
    ),
    headlineMedium: base.headlineMedium?.copyWith(
      color: primaryColor,
      fontWeight: FontWeight.w600,
      fontSize: 20,
    ),
    headlineSmall: base.headlineSmall?.copyWith(
      color: primaryColor,
      fontWeight: FontWeight.w600,
      fontSize: 18,
    ),
    titleLarge: base.titleLarge?.copyWith(
      color: primaryColor,
      fontWeight: FontWeight.w600,
      fontSize: 16,
    ),
    bodyLarge: base.bodyLarge?.copyWith(
      color: primaryColor,
      fontSize: 15.0,
      height: 1.4,
    ),
    bodyMedium: base.bodyMedium?.copyWith(
      color: secondaryColor,
      fontSize: 14.0,
      height: 1.4,
    ),
    labelLarge: base.labelLarge?.copyWith(
      color: primaryColor,
      fontWeight: FontWeight.w600,
      fontSize: 14.0,
    ),
    labelMedium: base.labelMedium?.copyWith(
      color: primaryColor.withOpacity(0.7),
      fontWeight: FontWeight.w500,
    ),
    labelSmall: base.labelSmall?.copyWith(
      color: secondaryColor,
      fontSize: 11.0,
    ),
  ).apply(
    fontFamily: 'Inter',
    displayColor: primaryColor,
    bodyColor: primaryColor,
  );
}

InputDecorationTheme _buildInputDecorationTheme({
  required Color fillColor,
  required Color hintColor,
  required Color focusBorderColor,
  bool useOutline = false,
}) {
  InputBorder borderStyle = useOutline
      ? OutlineInputBorder(
    borderRadius: BorderRadius.circular(25.0),
    borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
  )
      : OutlineInputBorder(
    borderRadius: BorderRadius.circular(25.0),
    borderSide: BorderSide.none,
  );

  InputBorder focusedBorderStyle = OutlineInputBorder(
    borderRadius: BorderRadius.circular(25.0),
    borderSide: BorderSide(color: focusBorderColor, width: 1.5),
  );

  return InputDecorationTheme(
    filled: true,
    fillColor: fillColor,
    hintStyle: TextStyle(color: hintColor),
    border: borderStyle,
    enabledBorder: borderStyle,
    focusedBorder: focusedBorderStyle,
    contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
    suffixIconColor: hintColor,
  );
}

ChipThemeData _buildChipThemeData({
  required Color backgroundColor,
  required Color labelStyleColor,
}) {
  return ChipThemeData(
    backgroundColor: backgroundColor,
    labelStyle: TextStyle(color: labelStyleColor, fontSize: 11.5),
    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    side: BorderSide.none,
    iconTheme: IconThemeData(color: labelStyleColor, size: 14),
  );
}

// Light Theme
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFF8F9FA),
  primaryColor: const Color(0xFF4361EE), // Vibrant blue
  hintColor: const Color(0xFF3A86FF), // Lighter blue
  fontFamily: 'Inter',
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF4361EE),
    secondary: Color(0xFFE9ECEF),
    surface: Colors.white,
    background: Color(0xFFF8F9FA),
    error: Color(0xFFE63946),
    onPrimary: Colors.white,
    onSecondary: Color(0xFF212529),
    onSurface: Color(0xFF212529),
    onBackground: Color(0xFF212529),
    onError: Colors.white,
    surfaceVariant: Color(0xFFE9ECEF),
    onSurfaceVariant: Color(0xFF495057),
    errorContainer: Color(0xFFFFD6D9),
    onErrorContainer: Color(0xFFE63946),
  ),
  textTheme: _buildTextTheme(
    base: ThemeData.light().textTheme,
    primaryColor: const Color(0xFF212529),
    secondaryColor: const Color(0xFF495057),
  ),
  inputDecorationTheme: _buildInputDecorationTheme(
    fillColor: Colors.white,
    hintColor: const Color(0xFFADB5BD),
    focusBorderColor: const Color(0xFF3A86FF),
    useOutline: true,
  ),
  chipTheme: _buildChipThemeData(
    backgroundColor: const Color(0xFFE9ECEF),
    labelStyleColor: const Color(0xFF495057),
  ),
  iconTheme: const IconThemeData(color: Color(0xFF3A86FF)),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: Color(0xFF3A86FF),
    circularTrackColor: Color(0xFFE9ECEF),
  ),
  dividerTheme: const DividerThemeData(
    color: Color(0xFFE9ECEF),
    thickness: 1,
    space: 1,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0.5,
    titleTextStyle: TextStyle(
      color: Color(0xFF212529),
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: IconThemeData(color: Color(0xFF3A86FF)),
    foregroundColor: Color(0xFF212529),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF3A86FF),
    foregroundColor: Colors.white,
    disabledElevation: 0,
  ),
);

// Dark Theme
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF121212),
  primaryColor: const Color(0xFF4895EF), // Bright blue
  hintColor: const Color(0xFF4CC9F0), // Cyan
  fontFamily: 'Inter',
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF4895EF),
    secondary: Color(0xFF2B2D42),
    surface: Color(0xFF1E1E1E),
    background: Color(0xFF121212),
    error: Color(0xFFF72585),
    onPrimary: Colors.white,
    onSecondary: Color(0xFFEDF2F4),
    onSurface: Color(0xFFEDF2F4),
    onBackground: Color(0xFFEDF2F4),
    onError: Colors.black,
    surfaceVariant: Color(0xFF2B2D42),
    onSurfaceVariant: Color(0xFF8D99AE),
    errorContainer: Color(0xFFFFD6E7),
    onErrorContainer: Color(0xFFF72585),
  ),
  textTheme: _buildTextTheme(
    base: ThemeData.dark().textTheme,
    primaryColor: const Color(0xFFEDF2F4),
    secondaryColor: const Color(0xFF8D99AE),
  ),
  inputDecorationTheme: _buildInputDecorationTheme(
    fillColor: const Color(0xFF1E1E1E),
    hintColor: const Color(0xFF6C757D),
    focusBorderColor: const Color(0xFF4CC9F0),
  ),
  chipTheme: _buildChipThemeData(
    backgroundColor: const Color(0xFF2B2D42),
    labelStyleColor: const Color(0xFF8D99AE),
  ),
  iconTheme: const IconThemeData(color: Color(0xFF4CC9F0)),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: Color(0xFF4CC9F0),
    circularTrackColor: Color(0xFF2B2D42),
  ),
  dividerTheme: const DividerThemeData(
    color: Color(0xFF2B2D42),
    thickness: 1,
    space: 1,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1F1F1F),
    elevation: 1.0,
    titleTextStyle: TextStyle(
      color: Color(0xFFEDF2F4),
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: IconThemeData(color: Color(0xFF4CC9F0)),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF4CC9F0),
    foregroundColor: Colors.black,
    disabledElevation: 0,
  ),
);

// Ocean Theme
final ThemeData oceanTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF001F24),
  primaryColor: const Color(0xFF00B4D8), // Bright teal
  hintColor: const Color(0xFF90E0EF), // Light teal
  fontFamily: 'Inter',
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF00B4D8),
    secondary: Color(0xFF003845),
    surface: Color(0xFF002A30),
    background: Color(0xFF001F24),
    error: Color(0xFFFF7D7D),
    onPrimary: Colors.black,
    onSecondary: Color(0xFFCAF0F8),
    onSurface: Color(0xFFCAF0F8),
    onBackground: Color(0xFFCAF0F8),
    onError: Colors.black,
    surfaceVariant: Color(0xFF003C43),
    onSurfaceVariant: Color(0xFF90E0EF),
    errorContainer: Color(0xFFFFD6D6),
    onErrorContainer: Color(0xFFFF7D7D),
  ),
  textTheme: _buildTextTheme(
    base: ThemeData.dark().textTheme,
    primaryColor: const Color(0xFFCAF0F8),
    secondaryColor: const Color(0xFF90E0EF),
  ),
  inputDecorationTheme: _buildInputDecorationTheme(
    fillColor: const Color(0xFF002A30),
    hintColor: const Color(0xFF5F8A8F),
    focusBorderColor: const Color(0xFF90E0EF),
  ),
  chipTheme: _buildChipThemeData(
    backgroundColor: const Color(0xFF003C43),
    labelStyleColor: const Color(0xFF90E0EF),
  ),
  iconTheme: const IconThemeData(color: Color(0xFF90E0EF)),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: Color(0xFF90E0EF),
    circularTrackColor: Color(0xFF003C43),
  ),
  dividerTheme: const DividerThemeData(
    color: Color(0xFF003C43),
    thickness: 1,
    space: 1,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF003C43),
    elevation: 1.0,
    titleTextStyle: TextStyle(
      color: Color(0xFFCAF0F8),
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: IconThemeData(color: Color(0xFF90E0EF)),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF90E0EF),
    foregroundColor: Colors.black,
    disabledElevation: 0,
  ),
);

// Sunset Theme
final ThemeData sunsetTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF1A1423),
  primaryColor: const Color(0xFFE56B6F), // Coral
  hintColor: const Color(0xFFF4A261), // Orange
  fontFamily: 'Inter',
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFFE56B6F),
    secondary: Color(0xFF372549),
    surface: Color(0xFF231F2A),
    background: Color(0xFF1A1423),
    error: Color(0xFFE9C46A),
    onPrimary: Colors.black,
    onSecondary: Color(0xFFF7F7F7),
    onSurface: Color(0xFFF7F7F7),
    onBackground: Color(0xFFF7F7F7),
    onError: Colors.black,
    surfaceVariant: Color(0xFF372549),
    onSurfaceVariant: Color(0xFFB8B8B8),
    errorContainer: Color(0xFFFFF3C8),
    onErrorContainer: Color(0xFFE9C46A),
  ),
  textTheme: _buildTextTheme(
    base: ThemeData.dark().textTheme,
    primaryColor: const Color(0xFFF7F7F7),
    secondaryColor: const Color(0xFFB8B8B8),
  ),
  inputDecorationTheme: _buildInputDecorationTheme(
    fillColor: const Color(0xFF231F2A),
    hintColor: const Color(0xFF6D6875),
    focusBorderColor: const Color(0xFFF4A261),
  ),
  chipTheme: _buildChipThemeData(
    backgroundColor: const Color(0xFF372549),
    labelStyleColor: const Color(0xFFB8B8B8),
  ),
  iconTheme: const IconThemeData(color: Color(0xFFF4A261)),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: Color(0xFFF4A261),
    circularTrackColor: Color(0xFF372549),
  ),
  dividerTheme: const DividerThemeData(
    color: Color(0xFF372549),
    thickness: 1,
    space: 1,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF231F2A),
    elevation: 1.0,
    titleTextStyle: TextStyle(
      color: Color(0xFFF7F7F7),
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: IconThemeData(color: Color(0xFFF4A261)),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFFF4A261),
    foregroundColor: Colors.black,
    disabledElevation: 0,
  ),
);