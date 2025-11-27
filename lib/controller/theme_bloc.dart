import 'package:dashboardpro/dashboardpro.dart';

class ThemeBloc {
  late AppTheme _currentTheme;
  final _themeController = StreamController<AppTheme>.broadcast();
  Stream<AppTheme> get themeStream => _themeController.stream;
  bool _isDarkMode = false;
  ColorSeed _currentColorSeed = ColorSeed.baseColor; // Default color seed

  AppTheme get currentTheme => _currentTheme;
  bool get isDarkMode => _isDarkMode; // Getter to check current mode
  ColorSeed get currentColorSeed => _currentColorSeed;

  ThemeBloc() {
    _currentTheme = AppTheme(data: buildAppTheme(_currentColorSeed.color));
    _themeController.sink.add(_currentTheme);
  }

  void dispose() {
    _themeController.close();
  }

  void toggleDarkMode(bool isDarkMode) {
    _isDarkMode = isDarkMode; // Update the mode flag
    _currentTheme = AppTheme(data: buildAppTheme(_currentColorSeed.color));
    _themeController.sink.add(_currentTheme);
  }

  void updateColorSeed(ColorSeed colorSeed) {
    _currentColorSeed = colorSeed;
    _currentTheme = AppTheme(data: buildAppTheme(colorSeed.color));
    _themeController.sink.add(_currentTheme);
  }

  // Set Default Theme
  ThemeData buildAppTheme(Color seedColor) {
    return ThemeData(
      pageTransitionsTheme: NoTransitionsOnWeb(),
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 0.0,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: const CardThemeData(
        shadowColor: Colors.transparent,
      ),
    );
  }
}

final themeBloc = ThemeBloc();